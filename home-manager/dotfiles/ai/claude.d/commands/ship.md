---
description: Autonomous end-to-end delivery — spec → plan → implement → verify → commit → push, auto-deciding with best recommendation
argument-hint: <task / feature / bug to ship>
---

# Mission

You are in **autonomous delivery mode**. Take the task below from idea to shipped code in one continuous run: write a spec, make a plan, implement it, verify it works, then commit and push. Drive the whole loop yourself — do not hand control back to the user between phases.

# Task

$ARGUMENTS

> If `$ARGUMENTS` is empty: STOP and ask the user what to ship. That is the only acceptable stop before starting.

# Decision policy (the core rule)

Whenever you hit a fork in the road:

1. **Make the call yourself.** Pick the option you would recommend as the best one and proceed. Briefly note the decision in your running narration (one line: `Decision: chose X over Y because Z`) — do not pause for approval.
2. **If a tool / skill / sub-agent offers a recommendation, take the recommended option.** Only deviate when you have a concrete, stated reason it's wrong here.
3. **Bias toward action over asking.** Reasonable defaults beat blocking. A wrong-but-recoverable choice that you verify and fix is better than stopping the flow.
4. **Never ask a question you can answer** by reading the code, the repo conventions, the git history, or by trying it and checking the result.

# When to STOP and ask (only these)

Stop the autonomous loop and ask the user **only** when one of these is true:

- **Destructive / irreversible** action not covered by the repo's standing git authorization — e.g. force-push to `main`, hard reset of a shared branch, deleting someone else's remote branch, `git push --force`, dropping data, changing repo visibility, deleting files you did not create.
- **Genuinely ambiguous core requirement** where the options lead to materially different products AND no reasonable default exists — i.e. guessing wrong would waste significant work that can't be cheaply undone. (A minor naming/structure choice does NOT qualify — decide it.)
- **Missing access**: a required secret, credential, token, account, or external resource you cannot obtain.
- **Security / safety / legal risk**: the task or a needed step looks unsafe, abusive, or out of scope for authorized work.

For everything else: decide and keep moving. The repo's standing authorization already permits committing, pushing commits + tags, and fast-forward merging feature branches into `main` — use it without asking.

# Workflow

Run these phases in order. Narrate each phase start with a one-line header so the user can follow. Use the relevant superpowers skills (`writing-plans`, `test-driven-development`, `verification-before-completion`, `systematic-debugging`, `finishing-a-development-branch`) — but in autonomous mode: invoke them, follow their discipline, and auto-proceed through their checkpoints instead of waiting for the user.

1. **Orient.** Read the parts of the codebase the task touches. Identify the project's build / test / lint / format commands and its conventions (style, structure, commit message format). Note the current branch.

2. **Branch.** If on the default branch (`main`/`master`), create a descriptive feature branch (e.g. `feat/<slug>`, `fix/<slug>`) before changing anything. If already on a feature branch, stay on it.

3. **Spec.** Write a short spec to a file under the scratchpad dir (or `docs/` / repo plan dir if the project keeps specs there). Cover: goal, scope, acceptance criteria, explicit out-of-scope, and key decisions made. Keep it tight — bullets, not prose.

4. **Plan.** Break the spec into ordered, verifiable steps. List the files you expect to touch. State the verification command(s) up front.

5. **Implement.** Work through the plan. Match the surrounding code's idiom, naming, and comment density. Prefer editing existing files over adding new ones. Use TDD where the project already has a test harness or where tests are clearly sensible; do not bolt on a test framework a project doesn't use. Keep changes scoped to the task — no unrelated refactors.

6. **Verify.** Run the project's real build / tests / lint / typecheck. Show the actual output. If something fails, debug and fix it (systematic-debugging) and re-run until green. **Do not claim success without evidence** — per verification-before-completion, assertions follow observed output, never precede it.

7. **Ship.**
   - Stage only the files relevant to this task (`git add` specific paths; don't blindly `git add -A`).
   - Commit with a clear message in the repo's convention (Conventional Commits if the history uses it). **No `Co-Authored-By` line.**
   - Push to the remote tracking branch. If it's a feature branch and the task is a self-contained unit the user clearly wanted on `main`, you may fast-forward merge into `main` and push per standing authorization — otherwise push the feature branch.

8. **Report.** Give a concise summary: what shipped, the branch/commit, verification result (with the command run), every non-obvious decision you auto-made (the `Decision:` lines), and anything you deliberately left out of scope. Follow the user's language/formatting rules from CLAUDE.md for this final report.

# Guardrails

- Stay in scope. Ship the task, not a rewrite.
- Never fabricate verification results. Green means you ran it and saw green.
- If you hit a real STOP condition mid-flow, pause cleanly: report what's done, what's blocking, and the specific question — then wait.
