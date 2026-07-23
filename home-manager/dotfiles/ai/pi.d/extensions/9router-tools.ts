import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import {
  truncateHead,
  truncateTail,
  DEFAULT_MAX_BYTES,
  DEFAULT_MAX_LINES,
  formatSize,
} from "@earendil-works/pi-coding-agent";

const BASE_URL = process.env.ROUTER_ENDPOINT ?? "http://100.127.63.100:20128/v1";
const AUTH_TOKEN = "Bearer sk-d54741feb1e6e4f9-daczsm-92470a30";

export default function (pi: ExtensionAPI) {
  // Register provider so baseUrl responds to ROUTER_ENDPOINT env var dynamically
  pi.registerProvider("9router", { baseUrl: BASE_URL });

  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description:
      "Search the web using 9router search API. Returns title, URL, and snippet for each result. Use for finding current information, news, docs, etc.",
    promptSnippet: "Search the web for up-to-date information",
    promptGuidelines: [
      "Use web_search when you need current information beyond your training data cutoff, or when the user asks about recent events, news, or specific facts that may have changed.",
      "Use web_search before web_fetch when you need to first find relevant pages.",
    ],
    parameters: Type.Object({
      query: Type.String({ description: "Search query" }),
      max_results: Type.Optional(
        Type.Integer({
          description: "Max results (1-20, default 5)",
          minimum: 1,
          maximum: 20,
        }),
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const maxResults = params.max_results ?? 5;
      const res = await fetch(`${BASE_URL}/search`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: AUTH_TOKEN,
        },
        body: JSON.stringify({
          model: "search-combo",
          query: params.query,
          search_type: "web",
          max_results: maxResults,
        }),
      });

      if (!res.ok) {
        const errText = await res.text().catch(() => "unknown error");
        throw new Error(`9router search failed (${res.status}): ${errText}`);
      }

      const data = (await res.json()) as {
        results?: Array<{
          title?: string;
          url?: string;
          content?: string;
          snippet?: string;
        }>;
      };

      const results = data.results ?? [];
      if (results.length === 0) {
        return {
          content: [{ type: "text", text: "No results found." }],
          details: { results: [] },
        };
      }

      let text = results
        .map(
          (r, i) =>
            `[${i + 1}] ${r.title ?? "(no title)"}\n    URL: ${r.url ?? "(no URL)"}\n    ${r.snippet ?? r.content ?? "(no content)"}`,
        )
        .join("\n\n");

      const truncation = truncateHead(text, {
        maxLines: DEFAULT_MAX_LINES,
        maxBytes: DEFAULT_MAX_BYTES,
      });

      if (truncation.truncated) {
        text =
          truncation.content +
          `\n\n[Truncated: ${truncation.outputLines}/${truncation.totalLines} lines, ${formatSize(truncation.outputBytes)}/${formatSize(truncation.totalBytes)}]`;
      }

      return {
        content: [{ type: "text", text }],
        details: { results },
      };
    },
  });

  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description:
      "Fetch a URL's content as markdown using 9router web fetch API. Use after web_search to get full page content.",
    promptSnippet: "Fetch and extract content from a web page as markdown",
    promptGuidelines: [
      "Use web_fetch to retrieve the full content of a web page after finding it with web_search.",
      "Use web_fetch when the user provides a URL directly and wants its content summarized or analyzed.",
    ],
    parameters: Type.Object({
      url: Type.String({ description: "URL to fetch" }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
      const res = await fetch(`${BASE_URL}/web/fetch`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: AUTH_TOKEN,
        },
        body: JSON.stringify({
          model: "fetch-combo",
          url: params.url,
          format: "markdown",
        }),
      });

      if (!res.ok) {
        const errText = await res.text().catch(() => "unknown error");
        throw new Error(`9router fetch failed (${res.status}): ${errText}`);
      }

      const data = (await res.json()) as {
        content?: string;
        title?: string;
        url?: string;
        description?: string;
      };

      const content = data.content ?? "(no content)";
      const title = data.title ?? "(no title)";

      let text = `# ${title}\nURL: ${data.url ?? params.url}\n\n${content}`;

      const truncation = truncateTail(text, {
        maxLines: DEFAULT_MAX_LINES,
        maxBytes: DEFAULT_MAX_BYTES,
      });

      if (truncation.truncated) {
        text =
          truncation.content +
          `\n\n[Truncated: kept ${truncation.outputLines}/${truncation.totalLines} lines, ${formatSize(truncation.outputBytes)}/${formatSize(truncation.totalBytes)}]`;
      }

      return {
        content: [{ type: "text", text }],
        details: { title, url: data.url ?? params.url },
      };
    },
  });
}
