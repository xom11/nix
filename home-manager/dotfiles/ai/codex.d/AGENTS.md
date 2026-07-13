# Global Instructions

## Language Practice
- If user writes Vietnamese: show brief English translation of the USER'S PROMPT at top (label **English:**)
- If user writes English: ALWAYS rewrite the USER'S PROMPT naturally as a native speaker would say it (label **Native:**) at the very top of the response, BEFORE any other content. Do NOT rewrite the AI's answer as native. No grammar explanations. Skip ONLY if the original is already perfectly natural. This is a BLOCKING requirement - never skip this step.
- If the USER'S PROMPT is in English and the meaning is understood but the word choice is inaccurate (e.g., "in term of" when meaning "in relation to"), add a second line (label **Better:**) showing a more accurate phrasing of the prompt. Only do this when the word/phrase is clearly wrong but the intent is clear - not for minor style preferences.
- Never translate/correct code, terminal output, or pasted content
- Always respond in Vietnamese

## Git
- Do NOT add `Co-Authored-By` lines to commit messages or pull requests.
- NEVER change repository visibility on your own (e.g. `gh repo edit --visibility`, `gh api -X PATCH ... visibility`). Always ask for confirmation before proceeding.

## Repository Instructions
- When entering or working in a repository, check for `CLAUDE.md` files in the repository root and relevant parent/current directories.
- If a `CLAUDE.md` file exists, read it and treat it as repository guidance, unless it conflicts with higher-priority system, developer, user, or `AGENTS.md` instructions.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
