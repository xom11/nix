// Auto-continue: recover from provider streams that end without usable
// content, which makes opencode exit the agent loop silently. Two shapes:
//   - finish="unknown", zero tokens, no error (upstream #41469, #37852)
//   - a transient transport error recorded on the message (ECONNRESET,
//     SSE timeout, ...) instead of any content
// Watches message.updated events; on a match in a main session it re-prompts
// "Continue." up to MAX_RETRY times within WINDOW_MS, keeping at least
// MIN_GAP_MS between sends. User-initiated aborts are never retried.
// Subagent/title sessions are left alone.

import { appendFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'

const MAX_RETRY = 3
const WINDOW_MS = 10 * 60 * 1000
const DELAY_MS = 1500
const MIN_GAP_MS = 5000
const DEBUG = !!process.env.AUTO_CONTINUE_DEBUG
const dbg = (...a) => {
  const line = `[${new Date().toISOString()}] ${a.join(' ')}\n`
  try {
    appendFileSync(join(tmpdir(), 'auto-continue-debug.log'), line)
  } catch {}
}
if (DEBUG) dbg('module loaded', process.pid)

// Matched case-insensitively against "ErrorName: message". Deliberately
// narrow: permanent failures (400/404/410, auth, quota) must NOT loop.
const RETRYABLE_ERRORS = [
  'econnreset',
  'econnrefused',
  'socket hang up',
  'premature close',
  'fetch failed',
  'sse read timed out',
  'idle timeout',
  'no data received',
  'service unavailable',
  'gateway timeout',
  'overloaded',
  'rate limit',
  'too many requests',
]
const ABORT_ERRORS = ['messageabortederror', 'operation was aborted']

export function errorMatches(msg) {
  const e = msg?.error
  if (!e || typeof e !== 'object') return false
  const s = `${e.name ?? ''}: ${e.data?.message ?? e.message ?? ''}`.toLowerCase()
  if (ABORT_ERRORS.some((p) => s.includes(p))) return false
  return RETRYABLE_ERRORS.some((p) => s.includes(p))
}

export function shouldRecover(msg) {
  if (!msg || msg.role !== 'assistant') return false
  if (errorMatches(msg)) return true
  if (!msg.time?.completed) return false
  if (msg.error) return false
  if (msg.finish !== 'unknown') return false
  return (msg.tokens?.output ?? 0) === 0
}

export function nextAttempt(st, now, maxRetry = MAX_RETRY, windowMs = WINDOW_MS) {
  const fresh = !st || now - st.lastAt > windowMs
  const count = fresh ? 0 : st.count
  return { count, exhausted: count >= maxRetry }
}

export function isThrottled(st, now, minGapMs = MIN_GAP_MS) {
  return !!st?.lastSentAt && now - st.lastSentAt < minGapMs
}

const hook = async ({ client }) => {
  if (DEBUG) dbg('factory called', typeof client)
  const state = new Map()
  const handled = new Set()

  const toast = async (message, variant) => {
    try {
      await client.tui.showToast({ body: { message, variant, duration: 5000 } })
    } catch {}
  }

  return {
    event: async ({ event }) => {
      try {
        if (event?.type !== 'message.updated') return
        const info = event.properties?.info
        if (!info) return
        if (DEBUG)
          console.error(
            `[auto-continue] evt ${info.id?.slice(-6)} role=${info.role} finish=${info.finish} out=${info.tokens?.output} done=${!!info.time?.completed} err=${info.error ? info.error.name : 'n'}`,
          )

        if (!shouldRecover(info)) {
          if (info.role === 'assistant' && info.finish && info.finish !== 'unknown') {
            state.delete(info.sessionID)
          }
          return
        }
        if (handled.has(info.id)) return
        handled.add(info.id)
        if (handled.size > 500) handled.clear()

        const sid = info.sessionID
        const sess = await client.session.get({ path: { id: sid } })
        const row = sess?.data ?? sess
        if (row?.parentID) return

        const now = Date.now()
        const st = state.get(sid)
        const { count, exhausted } = nextAttempt(st, now)
        state.set(sid, { count: count + 1, lastAt: now, lastSentAt: st?.lastSentAt ?? 0 })

        if (exhausted) {
          await toast(
            `Provider dropped the stream again (${count}/${MAX_RETRY} auto-continues used). Send a message to retry manually.`,
            'error',
          )
          return
        }
        if (isThrottled(st, now)) return

        setTimeout(async () => {
          await toast(`Provider stream dropped — sending "Continue." (${count + 1}/${MAX_RETRY})`, 'warning')
          try {
            await client.session.prompt({
              path: { id: sid },
              body: { parts: [{ type: 'text', text: 'Continue.' }] },
            })
          } catch (err) {
            console.error('[auto-continue] prompt failed', err)
          }
        }, DELAY_MS)
      } catch (err) {
        console.error('[auto-continue]', err)
      }
    },
  }
}

export const server = hook
export const AutoContinue = hook
