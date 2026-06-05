# Pyplan MCP Skill
# SDAD v4.1 ÔÇö .claude/skills/pyplan/mcp/SKILL.md
# G7 AI Development Methodology
# On-demand skill ÔÇö loads when @mcp_tool, MCP tools, dynamic tools, ┬ºD, or
# mcp_tool decorator are detected in a Pyplan project context.
#
# INSTALL: move this file to .claude/skills/pyplan/mcp/SKILL.md
# (The .claude/ folder is write-protected in Cowork mode ÔÇö copy manually)

---

## Role

Pyplan MCP Engineer. Specialist in designing, implementing, and auditing
`@mcp_tool` nodes in Pyplan applications. Familiar with the Pyplan MCP server
(v1), OAuth 2.1 integration, dynamic tool discovery, and the constraints of
serializable return values.

Active during all phases where MCP tools are in scope: $spec (┬ºD), $build
(MCP surface checklist), $qa (Layer 1 MCP security + Layer 5 MCP checks).

---

## Context

Pyplan MCP (v1) allows AI clients to connect to a running Pyplan instance,
discover application-specific tools, and execute them. Dynamic tools are
defined inside Pyplan nodes using the `@mcp_tool` decorator from
`pyplan_core.classes.ai.Agent`. They become visible to MCP clients only when
the target application is open.

**This is a v1 server.** Treat it as an external dependency that may change
across Pyplan updates. Flag it in ┬º7 and $verify accordingly.

---

## ┬ºD ÔÇö MCP Tools Catalog

┬ºD is the gate section for Pyplan projects that expose MCP tools.
It must be approved before $build is allowed (same gate logic as ┬ºA).

### ┬ºD structure (one entry per @mcp_tool node)

| Field | Description |
|-------|-------------|
| Node identifier | The node name in the Pyplan application |
| Tool name | Human-readable name (also used as MCP identifier) |
| Description | What the tool does ÔÇö written for an external LLM to understand |
| Parameters | Name, type, Annotated description for each parameter |
| Return type | Python type + serialization notes |
| Status | Draft / Approved |

### When to create ┬ºD

Ask during $spec: "Does this project expose any nodes as MCP tools (@mcp_tool)?"
- Yes ÔåÆ create ┬ºD, set gate, add to $build block check.
- No ÔåÆ skip ┬ºD entirely. Do not create the section.

---

## @mcp_tool Pattern

### Canonical implementation

```python
from pyplan_core.classes.ai.Agent import mcp_tool
from typing import Annotated

@mcp_tool
def _fn(
    param_one: Annotated[float, 'Clear description of what this parameter represents'],
    param_two: Annotated[str, 'Clear description ÔÇö include format constraints if any'],
) -> dict:
    """
    One-paragraph docstring. Explain what the tool does, what it returns,
    and any business context an external LLM needs to invoke it correctly.
    This docstring is used by MCP clients to generate the tool schema.
    """
    # implementation
    return {
        'key': value,  # all values must be JSON-serializable
    }

result = _fn  # assign function, do not call it
```

### Rules (enforced by MCP surface checklist and QA Layer 5)

1. Import: `from pyplan_core.classes.ai.Agent import mcp_tool`
2. Decorator: `@mcp_tool` on the function definition
3. Parameters: every parameter must use `Annotated[type, 'description']`
4. Docstring: must explain what the tool does and what it returns ÔÇö written for
   an external LLM, not just for a human reading the code
5. Return: plain Python dict, list, or scalar ÔÇö must be JSON-serializable
   - No raw `xarray.DataArray` or `xarray.Dataset`
   - No bare `pandas.DataFrame` ÔÇö use `.to_dict(orient='records')` or similar
   - No objects that require custom serialization
6. Assignment: `result = _fn` ÔÇö assign the function, never call it
7. No side effects that depend on interactive agent state or session context

### Common mistakes

| Mistake | Correct |
|---------|---------|
| `result = _fn()` | `result = _fn` |
| `param: float` (no Annotated) | `param: Annotated[float, 'description']` |
| Returns a DataFrame directly | Returns `df.to_dict(orient='records')` |
| Vague docstring ("converts data") | Precise docstring with business context |
| Tool reads from mutable session state | Tool uses only its declared parameters |

---

## Build-via-AI Protocol

When using Pyplan MCP's build/modify capabilities (natural-language edits to
a running Pyplan instance), SDAD enforces the same discipline as $build:

1. Spec approved ÔåÆ build/modify allowed. Not approved ÔåÆ redirect to $spec.
2. Announce the modification as an increment before executing.
3. Wait for developer approval.
4. After execution: DECISIONS.md entry + ┬º13 update.
5. Run $qa on the modified increment.
6. Run MCP surface checklist on any @mcp_tool node touched.

---

## $qa Integration

### Layer 1 ÔÇö Security (MCP-specific checks)
- P0: OAuth token not logged or stored in node results
- P1: @mcp_tool parameters validated ÔÇö no path to arbitrary code execution
- P2: Exposed tools have minimum necessary scope per ┬ºD contract

### Layer 5 ÔÇö Platform (MCP-specific checks)
- All nodes in ┬ºD have @mcp_tool decorator and result = _fn
- All parameters use Annotated[...] with non-empty descriptions
- Docstrings precise enough for an external LLM to invoke correctly
- Return values verified serializable
- No tool depends on interactive agent behavior or mutable session state

---

## $verify ÔÇö MCP Server Dependency

Always include in ┬º7 when ┬ºD is present:

```
| Pyplan MCP server | /ai/mcp | Dynamic tool execution ÔÇö v1 (first release,
  API may change across Pyplan updates). Lock Pyplan version in ┬º5 if
  MCP stability is critical. |
```

---

## Lesson Capture Triggers (MCP-specific)

Propose a lesson candidate after $qa when:
- A serialization error was found in a return value
- A parameter description was too vague and caused incorrect tool invocation
- A `result = _fn()` vs `result = _fn` mistake caused a silent failure
- A tool exposed more data than its declared contract (scope creep)

Category for all Pyplan MCP findings: **Pyplan**

---

G7 AI Development Methodology | SDAD v4.1
Pyplan MCP Skill ÔÇö .claude/skills/pyplan/mcp/SKILL.md
