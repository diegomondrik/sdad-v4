#!/usr/bin/env python3
"""SDAD v6 -- I2 MCP tool linter (audit + build-time detection).

Parses a Python file (a Pyplan node export or fixture) and audits every
function decorated with @mcp_tool against the pyplan-mcp skill rules. Emits one
line per finding tagged with a unified severity band (BR-03) and exits 1 when
any finding is present, 0 when clean. AST-based (Pyplan is Python), so the
checks are real, not regex guesses.

Severity mapping (BR-03):
  CRITICAL  result = fn()   -- function called, not assigned (rule 6, silent fail)
  HIGH      untyped / non-Annotated parameter (rule 3)
  HIGH      likely non-serializable return (rule 5) -- medium confidence, labeled
  MEDIUM    missing or trivial docstring (rule 4)

Usage:  python3 mcp_lint.py <file.py>
"""
import ast
import sys

NON_SERIALIZABLE_HINTS = ("DataFrame", "to_dataframe", "DataArray", "Dataset")
CONVERSION_HINTS = ("to_dict", "tolist", "to_records", "to_json", "item")


def _is_mcp_tool(fn):
    for d in fn.decorator_list:
        if isinstance(d, ast.Name) and d.id == "mcp_tool":
            return True
        if isinstance(d, ast.Attribute) and d.attr == "mcp_tool":
            return True
        if isinstance(d, ast.Call):
            t = d.func
            if isinstance(t, ast.Name) and t.id == "mcp_tool":
                return True
            if isinstance(t, ast.Attribute) and t.attr == "mcp_tool":
                return True
    return False


def _is_annotated(annotation):
    # Annotated[type, 'desc'] parses as Subscript whose value is Name/Attribute 'Annotated'.
    if not isinstance(annotation, ast.Subscript):
        return False
    v = annotation.value
    if isinstance(v, ast.Name):
        return v.id == "Annotated"
    if isinstance(v, ast.Attribute):
        return v.attr == "Annotated"
    return False


def _src(node):
    try:
        return ast.dump(node)
    except Exception:
        return ""


def _check_return_serializable(fn, findings):
    # Heuristic (medium confidence): a Return of a name whose last assignment
    # builds a DataFrame/xarray without a conversion call, or a direct Return of
    # such a construction.
    assigns = {}
    for node in ast.walk(fn):
        if isinstance(node, ast.Assign):
            for tgt in node.targets:
                if isinstance(tgt, ast.Name):
                    assigns[tgt.id] = node.value
    for node in ast.walk(fn):
        if isinstance(node, ast.Return) and node.value is not None:
            rv = node.value
            dumped = _src(rv)
            # direct return of a DataFrame/xarray construction
            if any(h in dumped for h in NON_SERIALIZABLE_HINTS) and not any(
                c in dumped for c in CONVERSION_HINTS
            ):
                findings.append(
                    ("HIGH", "non-serializable-return", node.lineno,
                     "returns a likely non-serializable object (DataFrame/xarray) "
                     "without .to_dict()/.tolist() [confidence: medium]"))
                continue
            # return of a name assigned from such a construction
            if isinstance(rv, ast.Name) and rv.id in assigns:
                src_dump = _src(assigns[rv.id])
                if any(h in src_dump for h in NON_SERIALIZABLE_HINTS) and not any(
                    c in src_dump for c in CONVERSION_HINTS
                ):
                    findings.append(
                        ("HIGH", "non-serializable-return", node.lineno,
                         "returns '%s' built from a non-serializable object without "
                         "conversion [confidence: medium]" % rv.id))


def lint(path):
    with open(path, "r", encoding="utf-8") as fh:
        source = fh.read()
    try:
        tree = ast.parse(source, filename=path)
    except SyntaxError as e:
        print("mcp-tool-audit: cannot parse %s: %s" % (path, e))
        return 1, []

    findings = []
    tool_fn_names = set()

    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and _is_mcp_tool(node):
            tool_fn_names.add(node.name)
            # parameters
            args = node.args
            params = list(args.posonlyargs) + list(args.args) + list(args.kwonlyargs)
            for a in params:
                if a.arg in ("self", "cls"):
                    continue
                if a.annotation is None:
                    findings.append(
                        ("HIGH", "untyped-param", a.lineno,
                         "parameter '%s' has no type annotation (rule 3: use "
                         "Annotated[type, 'desc'])" % a.arg))
                elif not _is_annotated(a.annotation):
                    findings.append(
                        ("HIGH", "non-annotated-param", a.lineno,
                         "parameter '%s' is annotated but not via Annotated[...] "
                         "(rule 3)" % a.arg))
            # docstring
            doc = ast.get_docstring(node)
            if doc is None or len(doc.strip()) < 10:
                findings.append(
                    ("MEDIUM", "weak-docstring", node.lineno,
                     "function '%s' has a missing or trivial docstring (rule 4: an "
                     "external LLM relies on it)" % node.name))
            # return serializability
            _check_return_serializable(node, findings)

    # module-level: result = fn()  vs  result = fn
    for node in ast.walk(tree):
        if isinstance(node, ast.Assign):
            for tgt in node.targets:
                if isinstance(tgt, ast.Name) and tgt.id == "result":
                    if isinstance(node.value, ast.Call):
                        called = node.value.func
                        name = called.id if isinstance(called, ast.Name) else (
                            called.attr if isinstance(called, ast.Attribute) else "")
                        if name in tool_fn_names:
                            findings.append(
                                ("CRITICAL", "result-called", node.lineno,
                                 "result = %s() calls the function; assign it instead: "
                                 "result = %s (rule 6, silent failure)" % (name, name)))

    rc = 1 if findings else 0
    return rc, findings


def main():
    if len(sys.argv) < 2:
        print("mcp-tool-audit: usage: mcp_lint.py <file.py>")
        return 1
    path = sys.argv[1]
    rc, findings = lint(path)
    if findings:
        print("mcp-tool-audit: %d finding(s) in %s" % (len(findings), path))
        for sev, rule, line, msg in findings:
            print("  [%s] %s (line %d): %s" % (sev, rule, line, msg))
    else:
        print("mcp-tool-audit: OK (%s)" % path)
    return rc


if __name__ == "__main__":
    sys.exit(main())
