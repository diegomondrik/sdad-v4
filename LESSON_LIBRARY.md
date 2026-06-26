# LESSON LIBRARY — SDAD

Transferable lessons captured across SDAD projects. Surfaced automatically in Phase 0
(2-3 most relevant) and searchable with `$lesson search [keyword]`.

## Conventions
- Each entry is `L-XX` and carries tags: `#stack:<tech>` and `#phase:<spec|build|qa|...>`.
- Retrieval (C-006): keyword + tag matching against this file. No embeddings while the library
  is small; migrate to embeddings only past ~50 entries.
- Categories: LLM Design | Architecture | Data & Debugging | Environment | Workflow | Pyplan.

---

## L-01 — PowerShell hooks must be pure-ASCII and handle UTF-8 explicitly
- **Category:** Environment
- **Tags:** `#stack:powershell` `#stack:windows` `#phase:build`
- **Signal:** A `.ps1` hook (or any PowerShell script) that contains non-ASCII characters
  (em-dash `—`, arrows `→`, `§`, `≤`) fails to parse on Windows, or reads/writes mojibake
  (`â€"`, `Â§`), even though the file is valid UTF-8.
- **Principle:** Windows PowerShell 5.1 reads `.ps1` files using the system codepage, not UTF-8.
  Keep script *source* pure-ASCII, and read/write *data* with explicit `-Encoding UTF8`
  (and set `[Console]::OutputEncoding = [Text.Encoding]::UTF8` for stdout). Always test hooks
  on real Windows before shipping — the bug is silent otherwise.
- **Origin:** SDAD v4.2 Track B (hooks). Caught by the mandatory Windows test gate.

### L-02 — Validate single-source rules against real workflows: the premise can be wrong even when the rule is right
- **Category:** Workflow
- **Tags:** `#stack:methodology` `#phase:spec` `#phase:qa`
- **Signal:** A rule or requirement is justified by a single source (one video, one developer, one
  anecdote). The justification sounds plausible but was never checked against your own real usage.
- **Principle:** Validate single-source assumptions against at least one real workflow before locking
  them — and separate two questions: "is the rule useful?" vs "is the stated reason true?". Two SDAD
  v4.2 rules passed only after their *premise* was corrected: C-011 assumed "many simultaneous MCPs
  degrade context" (G7 runs few — the real value is the security gate), and C-012 assumed
  "multi-author drift" (one maintainer today — the real value is an auto-reminder + future team
  scaling). Both rules stayed; their reasons changed. Keep the rule, fix the reason.
- **Origin:** SDAD v4.2 §2.1 single-source validation, closed with the G7 source 2026-06-07.

### L-03 — PS 5.1: native-command stderr under EAP Stop becomes a terminating error
- **Category:** Environment
- **Tags:** `#stack:powershell` `#stack:windows` `#phase:build` `#phase:qa`
- **Signal:** A PowerShell 5.1 script that invokes a child native command (an `.exe`, or
  `powershell -File child.ps1`) crashes with `NativeCommandError` exactly when the child
  writes to stderr — even though the child's exit code is the expected one. Adding `2>$null`
  makes it worse instead of fixing it (the redirection is what wraps stderr lines into
  ErrorRecords).
- **Principle:** In Windows PowerShell 5.1, any stderr line from a native command running
  under `$ErrorActionPreference = "Stop"` becomes a terminating error. When the child's
  stderr is *expected output* (e.g. a deny message from a gate hook), relax EAP to
  `Continue` around that single call and validate by `$LASTEXITCODE`, not by absence of
  error records. Sibling of L-01: same root cause family (PS 5.1 legacy semantics), so
  test harnesses for hooks must run on real Windows.
- **Origin:** SDAD v5 I1 — eval scenario 01 crashed while the gate hook under test behaved
  correctly (deny + stderr message). Caught by the Windows test gate, fixed in the scenario.

### L-04 — Reference CLAUDE.md by its exact case on case-sensitive surfaces
- **Category:** Environment
- **Tags:** `#stack:git` `#stack:github` `#stack:powershell` `#phase:build`
- **Signal:** A path, URL, or git ref to the methodology file written as `Claude.md` (mixed
  case) instead of `CLAUDE.md` (all caps). On a case-*insensitive* dev machine (Windows/macOS
  default) it works, so the bug is invisible locally — then fails silently on a case-*sensitive*
  surface: GitHub raw 404s the download, `git show <tag>:Claude.md` / `git ls-tree` find nothing,
  a Linux CI checkout misses the file. The failure is a no-op, not an error, so it hides.
- **Principle:** On case-sensitive surfaces (GitHub raw, git object refs, Linux FS) reference the
  file by its exact tracked name, `CLAUDE.md`. This recurred twice in v5 — the I9 budget assert
  (`git show v4.3:Claude.md` silently no-opped, so the +60-line gate never ran) and the I10
  installer URL (`$REPO/Claude.md` would 404 on a fresh install). Like L-01, a recurrence is the
  signal to move the rule from prose to code: `checks/claude-md-case.{ps1,sh}` flags the wrong
  case in code/config (prose may name it), wired as eval scenario 13.
- **Origin:** SDAD v5 I9 (budget assert) + I10 (installer fetch). Mechanically ratcheted in I10.

### L-05 — A CI gate that runs repo-resident scripts from the PR checkout can be neutered by the same PR
- **Category:** Architecture
- **Tags:** `#stack:github` `#stack:ci` `#phase:build`
- **Signal:** A pipeline runs a control script (lint, gate, ratchet, policy) that lives in the
  repo and, on a `pull_request` event, executes *from the PR's own checkout*. The control looks
  authoritative but a single malicious or careless PR can edit the control script to always pass
  AND introduce the very change the control exists to block — the neutered gate approves itself.
- **Principle:** A server-side control is only trustworthy if it runs from a *trusted ref* (check
  out the base branch's version of the control and run that against the PR's diff) or is protected
  from same-PR edits (CODEOWNERS + required review on the control's files). Branch protection
  alone is not enough; the code that enforces it must itself be out of the PR's reach. Note:
  CODEOWNERS/required-review only enforces under a GitHub Organization on a paid plan — on free
  private repos it is advisory, so the run-from-base mitigation is the portable one.
- **Origin:** SDAD v5.1 INC-1 ($qa finding H-01). Fix (run gate from base ref) + its check
  deferred to INC-2 — guardrail lands with the fix, per the lesson-to-ratchet protocol.

### L-06 — Self-tests must be hermetic: never depend on installed or machine state
- **Category:** Environment
- **Tags:** `#stack:ci` `#stack:github` `#phase:build`
- **Signal:** A test or eval passes on the author's machine but fails on a clean CI runner
  because it reads artifacts that only an installed/used environment has — an installed git
  hook, a globally-installed CLI, prior-run state — instead of building its own fixtures.
  The failure looks like a CI flake but is really a hidden dependency on local state.
- **Principle:** A regression suite must construct everything it needs inside the test
  (build the hook from a known body, stub the CLI, create the scratch repo) and depend only
  on what ships in the repo checkout. The clean-runner CI matrix is itself the ratchet: it
  fails any non-hermetic scenario automatically, so no extra check is needed — the guardrail
  is "run the suite on a freshly checked-out runner."
- **Origin:** SDAD v5.1 INC-2b ($qa finding H-02). Scenario 07-precommit-blocks copied an
  installed `.git/hooks/pre-commit` (absent on a clean runner); fixed to construct the hook
  itself. Confirmed green on the GitHub Actions windows runner.

### L-07 — A code-ratchet must cover every file with the same failure mode, not just the one that triggered the lesson
- **Category:** Workflow
- **Tags:** `#stack:powershell` `#stack:bash` `#phase:build`
- **Signal:** You have a guardrail enforced in code (a linter, ratchet, or check) that was
  born from a single concrete incident, and it scopes itself to *one* file type while sibling
  files share the identical failure mode but go unchecked. The rule reads as "done" but the
  hole is still open — a sibling file can reintroduce the exact bug the ratchet was meant to kill.
- **Principle:** When you convert a lesson into a mechanical check, audit its scope before
  closing: enumerate every file class that can fail the same way and make the check cover all
  of them. Extending the scan glob and the commit-time hook is cheap; discovering the gap in
  production is not. Pair the scope extension with a regression subcase so the wider coverage
  can't be silently reverted.
- **Origin:** SDAD v5.2 Pyplan versioning patch (I2b). L-01's ASCII ratchet covered only
  `.ps1`, but `install.sh` / `project-init.sh` broke on fresh machines the same way; extended
  `checks/ascii-ps1` (+ both installers' pre-commit glob) to `.ps1` + `.sh` and added eval
  subcases in 06-ascii-check. Complements [[L-01]].

### L-08 -- Verify a brief's factual claims against the real repo before accepting an increment's scope
- **Category:** Workflow
- **Tags:** `#stack:git` `#phase:build` `#phase:spec`
- **Signal:** A build brief asserts repo state as fact -- "this skill/file is missing", "must
  be built from scratch", "there are no other branches" -- and that assertion sets the scope
  and severity of an increment. The brief reads authoritative, so the claim is taken at face
  value and an increment is planned around it without a check.
- **Principle:** A brief is an input, not ground truth about the filesystem. Before accepting
  the scope of any increment that rests on a state claim, verify it cheaply against the repo
  (`git ls-files`, `git log -- <path>`, `git branch -a`, read the file). If reality differs,
  re-scope explicitly and record the correction as a numbered decision -- do not silently
  build to the wrong plan. Cheap to check now; expensive to discover after building from scratch
  something that already existed.
- **Origin:** SDAD v6 I2. The brief claimed `pyplan-mcp` was "absent from main... must be
  built, not recovered"; it existed on `main` (200 lines, v4.2, history from commit 6a6f233)
  and 6 branches existed. I2 was re-scoped HIGH-build -> MEDIUM-extend and logged as BR-16 in
  SPEC.md/DECISIONS.md before any code was written. Complements [[L-02]] (a premise can be
  wrong even when the surrounding plan is right).
