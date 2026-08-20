#!/usr/bin/env node

// MCP server: web_search + web_fetch through the custom router API.
// JSON-RPC 2.0 over stdio, zero dependencies.

import { env } from 'node:process';

// ROUTER_ENDPOINT is shared with opencode, where it is a baseURL and so always
// ends in /v1. Strip and re-append rather than relying on the router tolerating
// /v1/v1/... -- it happens to, but that is luck.
const BASE = (env.ROUTER_ENDPOINT ?? '').replace(/\/+$/, '').replace(/\/v1$/, '');
const API_KEY = env.ROUTER_KEY ?? env.ROUTER_API_KEY;

// Default to the cheapest provider. The "*-combo" aliases let the router pick at
// random, and the spread is up to 8x for the same query:
//   search -- serper $0.001 | exa $0.007 | tavily $0.008
//   fetch  -- exa    $0.001 | firecrawl $0.002 | tavily $0.008
const DEFAULT_SEARCH_PROVIDER = env.ROUTER_SEARCH_PROVIDER ?? 'serper';
const DEFAULT_FETCH_PROVIDER = env.ROUTER_FETCH_PROVIDER ?? 'exa';

// Character ceiling for web_fetch: a large page can be hundreds of KB, and
// dumping all of it into context defeats the purpose. 0 means unlimited.
const FETCH_MAX_CHARS = Number(env.ROUTER_FETCH_MAX_CHARS ?? 40000);

if (!BASE) {
  console.error('ROUTER_ENDPOINT env var required');
  process.exit(1);
}
if (!API_KEY) {
  console.error('ROUTER_KEY env var required');
  process.exit(1);
}

// ── helpers ──────────────────────────────────────────────────────

function rpc(id, result) {
  return JSON.stringify({ jsonrpc: '2.0', id, result }) + '\n';
}
function rpcError(id, code, message) {
  return JSON.stringify({ jsonrpc: '2.0', id, error: { code, message } }) + '\n';
}
function text(s) {
  return { content: [{ type: 'text', text: s }] };
}

async function post(path, body) {
  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${API_KEY}`,
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API ${res.status}: ${text.slice(0, 500)}`);
  }
  return res.json();
}

// ── formatting ───────────────────────────────────────────────────
// The router returns many null fields. Dumping raw JSON costs about 3x the
// context of text while carrying no extra information.

function cost(usage) {
  const c = usage?.search_cost_usd ?? usage?.fetch_cost_usd;
  return typeof c === 'number' ? ` · $${c}` : '';
}

function formatSearch(data) {
  const results = Array.isArray(data?.results) ? data.results : [];
  const head = `${data?.provider ?? '?'} · "${data?.query ?? ''}" · ${results.length} kết quả${cost(data?.usage)}`;

  const lines = [head];
  if (data?.answer) lines.push('', `Answer: ${data.answer}`);

  results.forEach((r, i) => {
    lines.push('', `${i + 1}. ${r.title || '(no title)'}`);
    if (r.url) lines.push(`   ${r.url}`);
    if (r.snippet) lines.push(`   ${r.snippet}`);
    // Some providers include page content; only pass it on when present.
    if (typeof r.content === 'string' && r.content.trim()) {
      lines.push(`   ${r.content.trim().replace(/\s+/g, ' ').slice(0, 500)}`);
    }
  });

  if (Array.isArray(data?.errors) && data.errors.length) {
    lines.push('', `errors: ${JSON.stringify(data.errors)}`);
  }
  if (!results.length) lines.push('', '(không có kết quả)');

  return lines.join('\n');
}

// Which fetch provider failed on which URL, for this process's lifetime. Without
// it, the escalation hint would suggest retrying the provider that just failed.
const FETCH_FAILURES = new Map();
const FETCH_FAILURES_MAX = 200;

const FETCH_PROVIDERS = [
  ['exa', 'rẻ nhất'],
  ['firecrawl', 'render JS tốt hơn'],
  ['tavily', 'hạ tầng khác'],
];

function noteFetchFailure(url, provider) {
  if (!url || !provider) return new Set();
  // Map preserves insertion order, so the first entry is the oldest -- enough to
  // bound memory in a long-running process.
  if (!FETCH_FAILURES.has(url) && FETCH_FAILURES.size >= FETCH_FAILURES_MAX) {
    FETCH_FAILURES.delete(FETCH_FAILURES.keys().next().value);
  }
  const seen = FETCH_FAILURES.get(url) ?? new Set();
  seen.add(String(provider).toLowerCase());
  FETCH_FAILURES.set(url, seen);
  return seen;
}

function formatFetch(data) {
  const body = data?.content?.text ?? '';
  const len = data?.content?.length ?? body.length;
  const truncated = FETCH_MAX_CHARS > 0 && body.length > FETCH_MAX_CHARS;

  const head = [
    data?.title || data?.url || '(no title)',
    `${data?.url ?? ''} · ${data?.provider ?? '?'}${cost(data?.usage)} · ${len} ký tự`,
  ].join('\n');

  // The router returns 200 with empty content when a provider cannot fetch the
  // page (dead domain, blocked, JS-only). Say so rather than returning whitespace.
  if (!body.trim()) {
    const failed = noteFetchFailure(data?.url, data?.provider);
    const left = FETCH_PROVIDERS.filter(([p]) => !failed.has(p));
    const hint = left.length
      ? `Thử lại với provider: ${left.map(([p, why]) => `"${p}" (${why})`).join(' hoặc ')}.`
      : 'Đã thử hết provider trên URL này — trang chặn cả ba, đừng gọi thêm cho tốn.';
    return `${head}\n\n[trống — provider "${data?.provider ?? '?'}" không lấy được nội dung. ${hint}]`;
  }

  const out = truncated ? body.slice(0, FETCH_MAX_CHARS) : body;
  const tail = truncated
    ? `\n\n[đã cắt: hiển thị ${FETCH_MAX_CHARS}/${body.length} ký tự — tăng ROUTER_FETCH_MAX_CHARS nếu cần trọn trang]`
    : '';

  return `${head}\n\n${out}${tail}`;
}

// ── MCP handlers ─────────────────────────────────────────────────

function handleInitialize(id) {
  return rpc(id, {
    protocolVersion: '2024-11-05',
    capabilities: {
      tools: {},
    },
    serverInfo: { name: 'router-search', version: '2.0.0' },
  });
}

function handleToolsList(id) {
  return rpc(id, {
    tools: [
      {
        name: 'web_search',
        description: 'Tìm kiếm web qua router API. Trả về kết quả dạng text.',
        inputSchema: {
          type: 'object',
          properties: {
            query: { type: 'string', description: 'Từ khóa tìm kiếm' },
            max_results: { type: 'number', description: 'Số kết quả tối đa (mặc định 5)' },
            search_type: { type: 'string', description: 'Loại tìm kiếm: web (mặc định), news, etc.' },
            provider: {
              type: 'string',
              description: `Nhà cung cấp: serper (rẻ nhất, mặc định), exa (chất lượng cao hơn), tavily, hoặc search-combo để router tự chọn. Mặc định ${DEFAULT_SEARCH_PROVIDER}.`,
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'web_fetch',
        description:
          'Tải nội dung trang web qua router API (fetch phía server — qua được trang chặn bot hoặc cần JavaScript). Trả về markdown hoặc text.',
        inputSchema: {
          type: 'object',
          properties: {
            url: { type: 'string', description: 'URL cần tải' },
            format: { type: 'string', description: 'Định dạng: markdown (mặc định) hoặc text' },
            provider: {
              type: 'string',
              description: `Nhà cung cấp: exa (rẻ nhất, mặc định), firecrawl (render JS tốt hơn), tavily, hoặc fetch-combo để router tự chọn. Mặc định ${DEFAULT_FETCH_PROVIDER}.`,
            },
          },
          required: ['url'],
        },
      },
    ],
  });
}

async function handleToolsCall(id, params) {
  const { name, arguments: args } = params ?? {};

  try {
    let result;

    if (name === 'web_search') {
      const data = await post('/v1/search', {
        model: args.provider ?? DEFAULT_SEARCH_PROVIDER,
        query: args.query,
        search_type: args.search_type ?? 'web',
        max_results: args.max_results ?? 5,
      });
      result = text(formatSearch(data));
    } else if (name === 'web_fetch') {
      const provider = args.provider ?? DEFAULT_FETCH_PROVIDER;
      // An outright refusal (a 403, say) is also a failure -- unrecorded, it would
      // be suggested again next time.
      const data = await post('/v1/web/fetch', {
        model: provider,
        url: args.url,
        format: args.format ?? 'markdown',
      }).catch((err) => {
        noteFetchFailure(args.url, provider);
        throw err;
      });
      result = text(formatFetch({ url: args.url, ...data }));
    } else {
      return rpcError(id, -32601, `Tool not found: ${name}`);
    }

    return rpc(id, result);
  } catch (err) {
    return rpcError(id, -32000, err.message);
  }
}

// ── stdio loop ───────────────────────────────────────────────────

// tools/call is async, so a closed stdin does not mean the work is done -- wait
// for in-flight requests before exiting.
let pending = 0;
let stdinEnded = false;

function maybeExit() {
  if (stdinEnded && pending === 0) process.exit(0);
}

async function handleLine(trimmed) {
  let msg;
  try { msg = JSON.parse(trimmed); } catch { return; }
  if (msg.jsonrpc !== '2.0') return;

  const { id, method, params } = msg;

  pending += 1;
  try {
    let response;
    switch (method) {
      case 'initialize':
        response = handleInitialize(id);
        break;
      case 'notifications/initialized':
        response = ''; // notification — no reply
        break;
      case 'tools/list':
        response = handleToolsList(id);
        break;
      case 'tools/call':
        response = await handleToolsCall(id, params);
        break;
      default:
        response = rpcError(id, -32601, `Method not found: ${method}`);
    }
    if (response) process.stdout.write(response);
  } catch (err) {
    if (id != null) {
      process.stdout.write(rpcError(id, -32603, err.message));
    }
  } finally {
    pending -= 1;
    maybeExit();
  }
}

let buffer = '';
process.stdin.setEncoding('utf-8');
process.stdin.on('data', (chunk) => {
  buffer += chunk;
  const lines = buffer.split('\n');
  buffer = lines.pop() ?? '';

  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed) handleLine(trimmed);
  }
});

process.stdin.on('end', () => {
  stdinEnded = true;
  maybeExit();
});
