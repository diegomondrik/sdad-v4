"""Fixture: an @mcp_tool node with planted defects. mcp_lint.py must detect:
  HIGH     untyped-param          (units)
  HIGH     non-annotated-param    (price: float, not Annotated)
  MEDIUM   weak-docstring         (trivial docstring)
  HIGH     non-serializable-return (returns a DataFrame)
  CRITICAL result-called          (result = _fn())
"""
from pyplan_core.classes.ai.Agent import mcp_tool
import pandas as pd


@mcp_tool
def _fn(
    units,
    price: float,
):
    """x"""
    df = pd.DataFrame({'u': [units], 'p': [price]})
    return df


result = _fn()
