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
