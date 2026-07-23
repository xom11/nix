#!/usr/bin/env node

// MCP server: web_search + web_fetch qua custom router API
// JSON-RPC 2.0 over stdio — zero dependencies

import { env } from 'node:process';

const ROUTER_ENDPOINT = env.ROUTER_ENDPOINT;
const API_KEY          = env.ROUTER_KEY ?? env.ROUTER_API_KEY;

if (!ROUTER_ENDPOINT) {
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

async function post(path, body) {
  const url = `${ROUTER_ENDPOINT}${path}`;
  const res = await fetch(url, {
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

// ── MCP handlers ─────────────────────────────────────────────────

function handleInitialize(id) {
  return rpc(id, {
    protocolVersion: '2024-11-05',
    capabilities: {
      tools: {},
    },
    serverInfo: { name: 'router-search', version: '1.0.0' },
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
            query:       { type: 'string', description: 'Từ khóa tìm kiếm' },
            max_results: { type: 'number', description: 'Số kết quả tối đa (mặc định 5)' },
            search_type: { type: 'string', description: 'Loại tìm kiếm: web (mặc định), news, etc.' },
          },
          required: ['query'],
        },
      },
      {
        name: 'web_fetch',
        description: 'Tải nội dung trang web qua router API. Trả về markdown hoặc text.',
        inputSchema: {
          type: 'object',
          properties: {
            url:    { type: 'string', description: 'URL cần tải' },
            format: { type: 'string', description: 'Định dạng: markdown (mặc định) hoặc text' },
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
      const body = {
        model: 'search-combo',
        query: args.query,
        search_type: args.search_type ?? 'web',
        max_results: args.max_results ?? 5,
      };
      const data = await post('/v1/search', body);
      result = { content: [{ type: 'text', text: JSON.stringify(data, null, 2) }] };
    } else if (name === 'web_fetch') {
      const body = {
        model: 'fetch-combo',
        url: args.url,
        format: args.format ?? 'markdown',
      };
      const data = await post('/v1/web/fetch', body);
      result = { content: [{ type: 'text', text: JSON.stringify(data, null, 2) }] };
    } else {
      return rpcError(id, -32601, `Tool not found: ${name}`);
    }

    return rpc(id, result);
  } catch (err) {
    return rpcError(id, -32000, err.message);
  }
}

// ── stdio loop ───────────────────────────────────────────────────

let buffer = '';
process.stdin.setEncoding('utf-8');
process.stdin.on('data', async (chunk) => {
  buffer += chunk;
  const lines = buffer.split('\n');
  buffer = lines.pop() ?? '';

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;

    let msg;
    try { msg = JSON.parse(trimmed); } catch { continue; }
    if (msg.jsonrpc !== '2.0') continue;

    const { id, method, params } = msg;

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
    }
  }
});

process.stdin.on('end', () => process.exit(0));
