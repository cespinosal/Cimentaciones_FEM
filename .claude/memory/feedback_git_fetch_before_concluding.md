---
name: feedback_git_fetch_before_concluding
description: "Always git fetch/check origin before telling the user a file or change doesn't exist in this repo"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 242f27b6-f098-4c5c-ad0d-16432ac0acb5
---

Before concluding a file "doesn't exist" or a change "wasn't made," run `git fetch` and compare
against `origin/main` — don't trust the initial `gitStatus` context blob or a plain local
`git status`, since neither fetches from remote.

**Why:** In this repo (worked from two machines — see [[project_hojafem]] and `WORKFLOW.md`), this
VM's clone was silently 4 commits behind `origin/main` (missing `help.html`, `WORKFLOW.md`, STAAD
export, and the ACI 318-19 structural-design section). I told the user `help.html` didn't exist
before checking the remote, when actually the local clone was just stale because nobody had run
`git pull` on this machine. `git status` said "up to date with origin/main" but that only reflects
the last fetch, which had never happened this session.

**How to apply:** In this repo specifically, run `git fetch --all` early in a session (or whenever
the user references something you can't find locally) before asserting something is missing or
out of date. If `origin/main` is ahead, pull (fast-forward is safe here) and re-derive any
docs/analysis from the updated files rather than the stale snapshot.
