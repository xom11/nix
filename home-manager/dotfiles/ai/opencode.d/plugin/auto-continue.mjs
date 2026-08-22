// Auto-continue: recover from the known upstream bug where a provider stream
// ends without any content and without an error (finish="unknown", zero
// tokens). opencode treats that as a normal end-of-turn and exits the agent
// loop silently (github.com/anomalyco/opencode/issues/41469, #37852).
//
// This plugin watches message.updated events; when a main-session assistant
// turn finishes empty+unknown it re-prompts the session with "Continue." up to
// MAX_RETRY times within WINDOW_MS, so a mid-task drop resumes instead of
// silently stopping. Subagent/title sessions are left alone.

import { appendFileSync } from 'node:fs'
import { tmpdir } from 'node:os'
import { join } from 'node:path'

const MAX_RETRY = 3
const WINDOW_MS = 10 * 60 * 1000
const DELAY_MS = 1500
const DEBUG = !!process.env.AUTO_CONTINUE_DEBUG
const dbg = (...a) => {
  const line = `[${new Date().toISOString()}] ${a.join(' ')}\n`
  try {
    appendFileSync(join(tmpdir(), 'auto-continue-debug.log'), line)
  } catch {}
}
if (DEBUG) dbg('module loaded', process.pid)

export function shouldRecover(msg) {
  if (!msg || msg.role !== 'assistant') return false
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
            `[auto-continue] evt ${info.id?.slice(-6)} role=${info.role} finish=${info.finish} out=${info.tokens?.output} done=${!!info.time?.completed} err=${info.error ? 'y' : 'n'}`,
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

        const status = await client.session.status({ path: { id: sid } })
        const srow = status?.data ?? status
        if (srow?.type && srow.type !== 'idle') return

        const now = Date.now()
        const { count, exhausted } = nextAttempt(state.get(sid), now)
        state.set(sid, { count: count + 1, lastAt: now })

        if (exhausted) {
          await toast(
            `Provider returned an empty stream again (${count}/${MAX_RETRY} auto-continues used). Send a message to retry manually.`,
            'error',
          )
          return
        }

        setTimeout(async () => {
          await toast(`Provider stream came back empty — sending "Continue." (${count + 1}/${MAX_RETRY})`, 'warning')
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
