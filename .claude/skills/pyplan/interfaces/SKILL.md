---
name: pyplan-interfaces
description: >
  Pyplan interface design and review expertise. Use when working on the
  user-facing side of a Pyplan application: creating or reviewing interfaces,
  configuring components (tables, charts, indicators, filters, inputs),
  setting up index synchronization, designing hierarchical filters,
  configuring input validations, applying styles and conditional formatting,
  or reviewing dashboard UX for planning and analytics apps. Does not cover
  node logic or Python code in the influence diagram — use pyplan-diagram
  for that.
license: G7 proprietary
metadata:
  author: G7 AI Development
  version: "4.0"
  platform: pyplan
---

# Pyplan Interfaces Skill

You are an expert Pyplan interface designer focused on the user-facing side
of a Pyplan application: dashboards, components, filters, inputs, and UX
patterns for planning and analytics tools.

---

## 1. Core Mental Model

An interface in Pyplan is a **screen made of components placed in a grid**.
Components read from and write to nodes in the influence diagram.

The relationship is:
- **Nodes → Interface:** output nodes (Variable, Report) feed tables, charts, indicators.
- **Interface → Nodes:** input components (Index, Input Data, Form, Cube) write values
  back to Input nodes, triggering recalculation of dependent nodes.

This skill covers the interface surface exclusively. When the task involves
node logic, data transformation, or Python code, switch to pyplan-diagram.

---

## 2. Component Categories

### 2.1 Data Display
| Component | Use for | Key configuration |
|-----------|---------|------------------|
| **Table** | Tabular data from DataFrame or xarray | Column format, conditional formatting, heatmap, editable cells |
| **Chart / Graph** | Visual trends, comparisons | Chart type, dimension, measure, series, pivot |
| **Indicator / KPI** | Single scalar value | Value format, font size, color, conditional format |
| **HTML** | Static rich text, images, custom layout | HTML content, dynamic HTML from node |

### 2.2 Filtering and Navigation
| Component | Use for | Key configuration |
|-----------|---------|------------------|
| **Index component** | Filter data by a dimension (Year, Region, Product) | Index node, mode (single/multi), format (tags/dropdown/slider/options) |
| **Filter component** | Row-level filter on a DataFrame | Source node, filter field, operator |
| **Menu component** | Navigate between interfaces | Link list, icons, layout |

### 2.3 Input and Actions
| Component | Use for | Key configuration |
|-----------|---------|------------------|
| **Input Data (scalar)** | Single editable value | Data type, validation rules (range, required) |
| **Table (editable)** | Form or Cube node editing | Bound to Form/Cube input node, editable cells |
| **Button** | Trigger an action (refresh, process, export) | Bound to Button node |
| **Upload Manager** | File upload from user | Bound to data reading node |

### 2.4 Process and Monitoring
| Component | Use for |
|-----------|---------|
| **Tasks** | Show background process status |
| **Notifications** | Display system messages |
| **Scheduled tasks** | Configure timed executions |

---

## 3. Index Components and Synchronization

Indexes are the most critical interface element in planning apps. Getting
index sync right determines whether the dashboard behaves correctly when
a user changes a filter.

### 3.1 How index sync works
When a user selects a value in an Index component (e.g. Year = 2025),
that selection propagates to all components that are configured to
listen to that index. Tables and charts update automatically.

For sync to work:
1. The Index component must be bound to the correct Index node.
2. The table/chart component must have **Index sync** enabled for
   that same index dimension.
3. The underlying node (DataFrame or xarray) must use that index
   as a dimension or column.

### 3.2 Step-by-step: connect an Index component to a Table
1. Add an **Index** component — bind to the `year` Index node.
2. Add a **Table** component — bind to the `sales_by_year` node.
3. In Table configuration → **Index sync** tab → check `year`.
4. Exit edit mode. Changing the year selection updates the table.

### 3.3 Index display formats
| Format | Best for |
|--------|---------|
| Tags (default) | Multi-select with chips — good for 5–15 values |
| Dropdown (Select) | Long lists (>15 values) — saves vertical space |
| Range slider | Numeric ranges (years, months) — intuitive for planning |
| Options list | Short lists (2–5 values) where all options should be visible |

### 3.4 Multi-index sync pattern
A common planning interface pattern: two related index components
where selecting a high-level value filters the lower-level options.

Example: Continent → Country
1. Index component A → `continent` Index node (single select).
2. Index component B → `country` Index node (depends on continent).
3. The `country` Index node code filters based on `continent` selection.
4. Table → Index sync: both `continent` and `country` enabled.

### 3.5 QA checklist for index sync
- [ ] Every Index component is bound to the correct Index node
- [ ] Every table/chart that should filter has Index sync enabled for
      the relevant dimensions
- [ ] Changing an index selection in preview mode updates all
      expected components
- [ ] Dependent indexes update correctly when a parent index changes
- [ ] No component shows stale data after an index change

---

## 4. Input Components

### 4.1 Scalar Input (single value)
Use for rates, thresholds, flags, or any single parameter a user adjusts.

Configuration checklist:
- [ ] Title set (visible label to the user)
- [ ] Data type configured: Float, Integer, String, Boolean, Date
- [ ] Validation rule set: Range (min/max for numbers), Required, Pattern (for strings)
- [ ] Default value defined (so the model has a starting state)

Example: discount rate input (0–100%)
- Data type: Float
- Validation: Range, min 0, max 100
- Default: 10

**Never leave an Input Scalar without a validation rule.** An unconstrained
input can receive values that break downstream calculations silently.

### 4.2 Form and Cube Inputs (tabular and multidimensional)
For structured data entry (budget tables, forecast inputs, plan matrices).

- **Form** — tabular input stored in DB. Users edit rows directly in a Table component.
- **Cube** — multidimensional input stored in DB. Used for multi-dimensional planning
  matrices (Product × Region × Month).

Configuration checklist:
- [ ] Input node created in the diagram (Form or Cube type)
- [ ] Fields/dimensions configured in the Input node wizard
- [ ] Table component in the interface is bound to the input node
- [ ] Cell editability enabled in Table component settings
- [ ] Save/refresh button present when data entry triggers a backend process

### 4.3 Selector Input
For single or multi-value selection from a predefined list.

- Source: can be bound to an Index node (dynamic list) or a static list.
- Use when the user needs to choose a scenario, a period, or a mode.

---

## 5. Charts and Visualization

### 5.1 Chart configuration
Every chart requires three elements:
1. **Dimension** — the X axis or grouping (e.g. Month, Product).
2. **Measure** — the Y axis value (e.g. Sales, Margin%).
3. **Series** *(optional)* — color grouping (e.g. Region, Scenario).

If the underlying node is an xarray DataArray, Pyplan maps dimensions
automatically. If it is a DataFrame, you configure the pivot manually
in the chart configuration panel.

### 5.2 Chart type selection guide
| Chart type | Best for |
|------------|---------|
| Column / Bar | Comparisons across categories (sales by product) |
| Line | Trends over time (monthly revenue) |
| Area | Cumulative trends or stacked contributions |
| Pie / Donut | Part-to-whole (max 5–6 segments — avoid for >6) |
| Scatter | Correlation between two measures |
| Waterfall | Variance analysis (budget vs actual bridge) |
| Heatmap | Matrix of values (product × region performance) |

### 5.3 Conditional formatting
Use to highlight exceptions without requiring a user to scan the table:

- Green / red for positive / negative variance.
- Traffic light (green/amber/red) for KPI thresholds.
- Progress bar in table cells for completion %.

Configure in component settings → Styles → Conditional format.
Always test conditional rules with edge values (zero, negative, maximum).

---

## 6. Interface Layout and UX Patterns

### 6.1 Planning app layout pattern
Recommended structure for a standard planning interface:

```
┌─────────────────────────────────────────────┐
│  HEADER: title + key KPI indicators (1 row) │
├──────────────┬──────────────────────────────┤
│  FILTERS     │  MAIN CONTENT                │
│  Index Year  │  Primary table or chart      │
│  Index Region│                              │
│  Index Prod  │                              │
├──────────────┴──────────────────────────────┤
│  SECONDARY: supporting chart or detail table│
└─────────────────────────────────────────────┘
```

- Filters on the left or top — never buried in the content area.
- KPI indicators at the top — give the user immediate context.
- Primary visualization dominant — secondary content below or in a tab.

### 6.2 Navigation pattern
For apps with multiple interfaces, always include a **Menu component** on
a home interface or in a persistent header:

- Use descriptive labels (not "Interface 1", "Interface 2").
- Group interfaces by business area (Demand, Finance, Supply, Summary).
- Set permissions per interface to control access by department.

### 6.3 Interface permissions
Each interface can have department-level access control:
- **View only:** standard users see the interface, cannot edit inputs.
- **Edit:** planning users can modify input values.
- **Hidden:** interface not visible to the department.

Configure in Interface Manager → context menu → Set Permissions.
Always verify permissions are set before publishing to Public workspace.

### 6.4 Edit vs view mode
Interfaces open in **view mode** by default for end users.
**Edit mode** is for developers — it exposes the component grid and
configuration panels. Never deliver an interface still open in edit mode.

---

## 7. Workspace and Publishing

### 7.1 Workspace types
| Workspace | Who sees it | When to use |
|-----------|------------|------------|
| My Apps (private) | Developer only | Development and testing |
| Teams | Department members | Shared development, UAT |
| Public Apps | All authorized users | Final published solution |

**Development flow:** build in My Apps → test in Teams with key users
→ publish to Public Apps when approved.

Never publish directly to Public Apps from My Apps without a Teams review.

### 7.2 Save As pattern
When creating a client-specific version of a base app:
1. Open the base app.
2. Save As → "Save application in my workspace" (for initial copy).
3. Rename to follow project naming convention.
4. Modify for the client's data sources and requirements.

### 7.3 Versioning
Pyplan supports multiple versions of an app. Use versions for:
- Scenario comparison (Base vs Optimistic vs Pessimistic).
- Period cycles (2024 Budget vs 2025 Budget).
- Rollback points before a major structural change.

---

## 8. QA Checklist — Interface Surface

Run these checks on every $qa for Pyplan projects (contributes to Layer 5):

- [ ] All Index components are bound to the correct Index nodes
- [ ] Index sync is enabled on all tables/charts that should respond to filters
- [ ] Changing each Index selection updates all expected components in preview
- [ ] All Input Scalar components have data type and validation rules configured
- [ ] All Input Scalar components have a default value set
- [ ] Form and Cube inputs have cell editability enabled where expected
- [ ] All charts have Dimension and Measure configured (no empty axes)
- [ ] Conditional formatting rules tested with edge values
- [ ] Interface titles and component titles are descriptive (no "Node Result", "Chart 1")
- [ ] Navigation menu present and links to all relevant interfaces
- [ ] Interface permissions set correctly per department before publishing
- [ ] No interface delivered still open in edit mode
- [ ] App published to correct workspace (My / Teams / Public) per deployment stage

---

## 9. Common Errors and Fixes

| Error | Likely cause | Fix |
|-------|-------------|-----|
| Table shows empty after index change | Index sync not enabled on table | Enable Index sync for the relevant dimension in table config |
| Chart shows no data | Dimension or Measure not configured | Open chart config and assign Dimension + Measure |
| Input change does not trigger recalculation | Input component not bound to an Input node | Check node binding in component config |
| Filter shows all values regardless of selection | Index node not correctly referenced in upstream node code | Verify the upstream node uses the Index node ID as filter |
| Interface opens in edit mode for end users | Edit mode not closed before saving | Exit edit mode, then save the interface |
| Form cells not editable | Table component editability not enabled | Component config → enable cell editing |
| KPI shows wrong format | Value format not set | Component config → Styles → Value format |
| Department cannot see interface | Permission not set | Interface Manager → Set Permissions → add department |
