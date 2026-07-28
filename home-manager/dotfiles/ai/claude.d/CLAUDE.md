# Global Instructions

## Language Practice
- Always respond in Vietnamese

## Git
- Do NOT add `Co-Authored-By` lines to commit messages or pull requests.
- NEVER change repository visibility on your own (e.g. `gh repo edit --visibility`, `gh api -X PATCH ... visibility`). Always ask for confirmation before proceeding.
- Standing authorization: push commits + tags, fast-forward merge feature branches vào main, close GitHub issues/PRs sau khi work xong — không cần hỏi xác nhận từng lần. Vẫn confirm với destructive ops (force push to main, hard reset shared branches, delete remote branches của người khác).

## Web search & fetch

Escalate in this order — cheap and context-light first, paid escape hatch last.

**Search**
1. `WebSearch` — mặc định. Không tốn tiền router, có sẵn nguồn trích dẫn.
2. `mcp__router-search__web_search` — khi WebSearch không ra, bị giới hạn khu vực,
   hoặc cần một provider cụ thể. Mặc định `serper` ($0.001); `exa` cho tìm ngữ
   nghĩa/nội dung dài, `tavily` khi cần bản tóm tắt kèm answer.

**Fetch** — `WebFetch` và `curl`/`wget` đều bị hook context-mode chặn, đừng thử.
1. `ctx_fetch_and_index` — mặc định. Tải từ máy này rồi index vào knowledge base,
   chỉ summary vào context nên rẻ nhất về context.
2. `mcp__router-search__web_fetch` — khi cách trên trả về trang trắng, 403,
   Cloudflare, hoặc trang chỉ dựng nội dung bằng JavaScript. Router fetch phía
   server nên đôi khi qua được. Mặc định provider `exa` ($0.001); rỗng thì leo
   sang `firecrawl` (render JS tốt hơn) rồi `tavily` — bản thân tool sẽ báo còn
   provider nào chưa thử, hết thì nó nói thẳng, đừng gọi thêm.

   Đây **không** phải lối vòng vạn năng: reddit.com hiện chặn cả ba provider
   (firecrawl từ chối thẳng bằng 403), và `ctx_fetch_and_index` cũng thua nốt.
   Trang nào cả hai đều thua thì báo user, đừng đốt thêm lượt gọi.

Router là hạ tầng riêng của user (9router qua Tailscale) nhưng nó chuyển tiếp ra
serper/exa/tavily/firecrawl — SaaS bên ngoài, tính tiền theo lượt gọi. Nên đừng
gọi vòng hai khi lượt đầu đã đủ dùng.

Nếu tool `mcp__router-search__*` không có trong danh sách thì máy này chưa đăng ký
nó — dừng ở bước 1, đừng báo lỗi.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
