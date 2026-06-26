"""Fixture: a clean @mcp_tool node. mcp_lint.py must report 0 findings."""
from pyplan_core.classes.ai.Agent import mcp_tool
from typing import Annotated


@mcp_tool
def _fn(
    units: Annotated[float, 'Number of units sold in the period'],
    price: Annotated[float, 'Unit price in USD'],
) -> dict:
    """Compute total revenue from units and price. Returns a JSON-serializable
    dict with the revenue total, for an external LLM client to consume."""
    total = units * price
    return {'revenue': total}


result = _fn
