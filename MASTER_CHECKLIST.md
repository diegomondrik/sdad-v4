# SDAD v4.0 — Master Checklist
# Instructions for every session:
# 1. Read this file at the start of the session
# 2. Build whatever is requested
# 3. Mark completed items with [x] and add date
# 4. Return the updated file to Diego at session end
# Last updated: 2026-06-03 (Session 5 — Phase 5 Documentation complete)

---

## DECISIONS — locked, do not reopen

- [x] ADR-001 infra-core: .claude/ folder, SKILL.md format, always-on vs on-demand skills,
      manual fallback session management
- [x] ADR-002 pyplan-layer: 4 Pyplan skills + decision-architecture + data-discovery,
      SPEC §0/§A/§B/§C, Pyplan checklist in $build, delta handling, no Analyst Agent dependency
- [x] ADR-003 repo-structure: everything in sdad-v4. g7-pyplan-hub cancelled.
      Revisit when G7 has multiple completed real projects.
- [x] ADR-004 brand-design: new transversal skill (Option B split) — brand-design extracts
      tokens and produces Brand Token Sheet, pyplan/interfaces and frontend consume tokens.
      Activated when §C is populated in SPEC.md.
- [x] ADR-005 documentation format: human-readable docs → HTML5 (INSTALL_GUIDE,
      USAGE_AND_SHORTCUTS, DEVELOPER_GUIDE, ONBOARDING_PYPLAN).
      Machine-readable docs → .md (CHANGELOG, all SKILL.md, CLAUDE.md, SPEC_blank.md).
      Rule: if a person reads it to understand something → HTML. If a computer reads it → MD.
- [x] ADR-006 SPEC §C Brand: new pre-body section §C added to SPEC_blank.md.
      Sequence: §0 → §A → §B → §C → §1...§13
      §C = Brand & Visual Identity. Applies to any project with UI — not Pyplan-specific.
      §C is omitted when no UI or no client brand identity.
      Lettered sections (§A, §B, §C...) were designed to grow — §C is the first extension.
- [x] PROJECT_PLATFORM: pyplan declared explicitly in CLAUDE.md (not auto-detected)
- [x] All artifacts written in English
- [x] Pyplan Analyst Agent: never relied upon — SDAD must be self-sufficient
- [x] Hooks: inactive in v4.0, .claude/hooks/ exists with README only, activate in v4.1
- [x] $build dual Pyplan (diagram/interface sub-increments): deferred to v4.1
- [x] C-020 decision-architecture: build from general best practices first,
      enrich later with G7 $input session

---

## PENDING DECISION SESSION

- [ ] $decide memoria-collab
      Items: C-004 prompt caching · C-006 retrieval Lesson Library · C-007 sliding window
             C-008 model auto-detect · C-009 git worktrees · C-010 subagents as agents/
      Can run in parallel with $build4 sessions

---

## ARTIFACTS — Phase 1: Pyplan Layer (complete)

- [x] CLAUDE.md v4.0 — 2026-06-02
- [x] .claude/skills/pyplan/diagram/SKILL.md — 2026-06-02
- [x] .claude/skills/pyplan/interfaces/SKILL.md — 2026-06-03 (v4.1 — brand section 8 + §C refs)
- [x] .claude/skills/pyplan/qa-platform/SKILL.md — 2026-06-02
- [x] .claude/skills/pyplan/spec-context/SKILL.md — 2026-06-02
- [x] .claude/skills/decision-architecture/SKILL.md — 2026-06-02
- [x] .claude/skills/data-discovery/SKILL.md — 2026-06-02
- [x] SPEC_blank.md (v4.0 with §0/§A/§B/§C) — 2026-06-03 (§C added)

---

## ARTIFACTS — Phase 2: SDAD Core Skills (complete)

- [x] .claude/skills/ai-architect/SKILL.md — 2026-06-02
- [x] .claude/skills/ai-engineer/SKILL.md — 2026-06-02
- [x] .claude/skills/compliance/SKILL.md — 2026-06-03
- [x] .claude/skills/qa-engineer/SKILL.md — 2026-06-03
- [x] .claude/skills/frontend/SKILL.md — 2026-06-03
- [x] .claude/skills/brand-design/SKILL.md — 2026-06-03 (NEW — transversal, §C refs corrected)

---

## ARTIFACTS — Phase 3: Agents (complete)

- [x] .claude/agents/code-reviewer.md — 2026-06-03
- [x] .claude/agents/test-generator.md — 2026-06-03
- [x] .claude/agents/security-auditor.md — 2026-06-03

---

## ARTIFACTS — Phase 4: Infrastructure (complete)

- [x] install.ps1 — 2026-06-02
- [x] install.sh — 2026-06-02
- [x] project-init.ps1 — 2026-06-03
- [x] project-init.sh — 2026-06-03
- [x] .claude/hooks/README.md — 2026-06-03
- [x] README.md v4.0 — 2026-06-03

---

## ARTIFACTS — Phase 5: Documentation (complete — session 5)

- [x] docs/INSTALL_GUIDE_v4.html — 2026-06-03
- [x] docs/USAGE_AND_SHORTCUTS_v4.html — 2026-06-03
- [x] docs/ONBOARDING_PYPLAN_v4.html — 2026-06-03
- [x] CHANGELOG.md — 2026-06-03
- [x] docs/DEVELOPER_GUIDE_v4.html — 2026-06-03

---

## DEFERRED — v4.1 (do not build in v4.0)

- [ ] Hooks automation: PostToolUse.sh, SessionStart.sh, PreCompact.sh
- [ ] $build dual Pyplan: sub-increments 3.1a (diagram) / 3.1b (interface)
- [ ] Prompt caching (depends on $decide memoria-collab)
- [ ] Model auto-detection replacing manual $SM (depends on $decide memoria-collab)
- [ ] Git worktrees for multi-developer collab (depends on $decide + Windows validation)

---

## PENDING $input SESSIONS

- [ ] G7 data architecture best practices → enrich decision-architecture skill
- [ ] Additional ecosystem inputs → catalog growth for $decide memoria-collab

---

## CONSTRAINTS (carry into every session)

- Diego has no technical programming background — verifications must be doable in
  Claude Code/Cowork OR packaged as developer brief. Never ask Diego to run bash,
  edit config files, or interpret code directly.
- All artifacts in English — design sessions run in Spanish
- Pyplan Analyst Agent is immature — never depend on it
- Hooks folder exists but is empty in v4.0
- decision-architecture skill: base version from general best practices only
- Repo: diegomondrik/sdad-v4 (private)
- brand-design is transversal — applies to Pyplan AND web/frontend projects
- pyplan/interfaces v4.1 replaces v4.0 at same path
- Documentation format rule: human reads → HTML5 | computer reads → MD
- SPEC lettered sections (§A, §B, §C...): optional, extensible, omit when not applicable

---

## NEXT RECOMMENDED ACTION

SDAD v4.0 is feature-complete. All phases (1–5) are done.

Recommended next sessions (any order):
  A. $decide memoria-collab — resolve C-004, C-006, C-007, C-008, C-009, C-010
     (prerequisite for most v4.1 features)
  B. $input G7 data architecture best practices → enrich decision-architecture skill
  C. Begin v4.1 planning session once $decide memoria-collab is resolved
