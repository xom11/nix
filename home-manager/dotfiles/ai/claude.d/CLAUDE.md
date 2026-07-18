# Global Instructions

## Language Practice
- Always respond in Vietnamese

## Git
- Do NOT add `Co-Authored-By` lines to commit messages or pull requests.
- NEVER change repository visibility on your own (e.g. `gh repo edit --visibility`, `gh api -X PATCH ... visibility`). Always ask for confirmation before proceeding.
- Standing authorization: push commits + tags, fast-forward merge feature branches vào main, close GitHub issues/PRs sau khi work xong — không cần hỏi xác nhận từng lần. Vẫn confirm với destructive ops (force push to main, hard reset shared branches, delete remote branches của người khác).

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
