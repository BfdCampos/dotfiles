---
name: visualisation
description: Generate self-contained HTML visualisations that explain complex information through interactive diagrams, architecture maps, timelines, comparisons, and visual reports. Use this skill when the user explicitly asks to visualise, diagram, or illustrate something (triggers include "visualise", "viz", "vis", "diagram", "illustrate", "make this visual", "create a visual report"). After explaining complex topics like architecture, data flows, plans, or comparisons, suggest this skill to the user by asking "Would you like me to visualise this for you?" The key differentiator from the playground skill is that this creates explanatory visual reports, not interactive configuration tools.
---

# Visualisation Skill

Generate beautiful, self-contained HTML files that explain complex information visually. The goal is to replace walls-of-text explanations with interactive, navigable, well-designed visual reports that make someone say "oh, now I get it" within seconds.

## When to use

### Explicit triggers (use immediately)

"visualise this", "viz", "vis", "diagram this", "illustrate this", "make this visual", "create a report", "show me visually", or any direct request for a visual output.

### Suggest after explaining (ask first, don't auto-trigger)

After completing a text explanation of something complex, consider whether a visual would genuinely help. If so, offer:

> "Would you like me to create an interactive visualisation of this? It might be easier to navigate than text."

Good candidates for suggestion: architecture with many components, data flow descriptions, comparisons between options, step-by-step processes, summaries of long documents, dependency relationships, anything where spatial layout communicates structure better than linear prose.

### Don't use when

- A short text answer is sufficient
- The user wants code, not explanation
- A Mermaid diagram in markdown would do the job (use the `mermaid` skill)
- The user wants an interactive configuration tool (use the `playground` skill)

### How this differs from related skills

- **Mermaid**: Quick diagrams embedded in markdown. Limited interactivity, great for PRs and docs.
- **Playground**: Interactive tools with controls, live preview, prompt output. A tool for configuring something.
- **Visualisation**: Explanatory visual reports. Takes information and presents it so someone understands it faster. A report for comprehension.

## Output conventions

### Location and naming

Default to `/tmp/`. The user may specify a different location.

```
/tmp/viz_<descriptive_topic>_<YYYYMMDD_HHMMSS>.html
```

Get the timestamp with `date +"%Y%m%d_%H%M%S"`.

Examples:
- `/tmp/viz_payment_service_architecture_20260415_143022.html`
- `/tmp/viz_migration_plan_comparison_20260415_150811.html`

### After writing

1. `open` the file so it launches in the browser
2. Tell the user the file path
3. If the user asks for changes, edit the existing file rather than creating a new one

### File requirements

- Single self-contained HTML file with all CSS and JS inline
- No external dependencies (no CDNs, no external fonts, no fetch calls)
- Works offline, shareable, archivable
- Proper `<!DOCTYPE html>`, charset, and viewport meta tags

## Design system

### Colour palette

Use CSS custom properties so the theme toggle is a clean palette swap. The palette below is the default. Adjust accent colours to suit the content when it helps (warmer tones for timelines, cooler for technical architecture), but keep the neutral base consistent.

```css
:root {
  --bg: #ffffff;
  --bg-surface: #f8fafc;
  --bg-muted: #f1f5f9;
  --bg-elevated: #ffffff;
  --text: #0f172a;
  --text-secondary: #475569;
  --text-muted: #94a3b8;
  --border: #e2e8f0;
  --border-strong: #cbd5e1;
  --primary: #6366f1;
  --primary-light: #eef2ff;
  --primary-dark: #4f46e5;
  --secondary: #0ea5e9;
  --secondary-light: #e0f2fe;
  --accent: #f59e0b;
  --accent-light: #fef3c7;
  --success: #10b981;
  --success-light: #d1fae5;
  --warning: #f59e0b;
  --warning-light: #fef3c7;
  --error: #ef4444;
  --error-light: #fee2e2;
  --info: #3b82f6;
  --info-light: #dbeafe;
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
  --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.1);
}

[data-theme="dark"] {
  --bg: #0f172a;
  --bg-surface: #1e293b;
  --bg-muted: #334155;
  --bg-elevated: #1e293b;
  --text: #f1f5f9;
  --text-secondary: #cbd5e1;
  --text-muted: #64748b;
  --border: #334155;
  --border-strong: #475569;
  --primary-light: #1e1b4b;
  --secondary-light: #0c4a6e;
  --accent-light: #451a03;
  --success-light: #064e3b;
  --warning-light: #451a03;
  --error-light: #450a0a;
  --info-light: #172554;
  --shadow-sm: 0 1px 2px rgba(0,0,0,0.3);
  --shadow-md: 0 4px 6px -1px rgba(0,0,0,0.4);
  --shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.4);
}
```

### Typography

```css
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 1rem;
  line-height: 1.6;
  color: var(--text);
  background: var(--bg);
}

code, pre {
  font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', 'JetBrains Mono', monospace;
  font-size: 0.875em;
}
```

Heading scale: h1 at 2rem, h2 at 1.5rem, h3 at 1.25rem, body at 1rem, small at 0.875rem, caption at 0.75rem.

### Spacing

Use a 4px base unit: `--space-1` (0.25rem) through `--space-16` (4rem). When in doubt, use more space, not less. Dense layouts make everything harder to parse.

### Theme toggle

Place in the top-right corner. Detect system preference on load, allow manual override, persist to localStorage.

```javascript
function initTheme() {
  const saved = localStorage.getItem('viz-theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  document.documentElement.setAttribute('data-theme', saved || (prefersDark ? 'dark' : 'light'));
}

function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme');
  const next = current === 'dark' ? 'light' : 'dark';
  document.documentElement.setAttribute('data-theme', next);
  localStorage.setItem('viz-theme', next);
}
```

Use a sun/moon icon (inline SVG) for the toggle button, not an emoji.

### Print styles

```css
@media print {
  [data-theme-toggle], .no-print { display: none !important; }
  body { background: white; color: black; }
  * { box-shadow: none !important; }
  details { display: block; }
  details > summary { display: none; }
}
```

## Content types and visual patterns

Detect the content type from context and choose the right visual approach. Combine patterns when the content calls for it.

| Content type | Visual approach | Key components |
|---|---|---|
| Architecture / system design | Node-edge diagram with component cards | SVG connections, expandable detail panels, colour-coded layers |
| Data flow / pipeline | Directional flow (LTR or TTB) | Stage cards with arrows, transformation annotations, hover metadata |
| Document summary | Structured card layout with hierarchy | Section cards, key findings as callouts, anchor navigation |
| Timeline / sequence | Vertical or horizontal timeline | Event nodes with connectors, detail panels, optional step-through |
| Comparison / trade-offs | Side-by-side panels or scoring matrix | Colour bars, checkmarks/crosses, toggle between options |
| Code walkthrough | Annotated code with step navigation | Numbered steps, highlighted regions, explanation panel alongside |
| Concept explanation | Layered diagram with progressive reveal | Build-up animation, annotations, relationship arrows |
| ERD / data model | Entity boxes with typed relationship lines | Hover to highlight related entities, cardinality labels |
| Decision tree | Branching layout with condition nodes | Expand/collapse branches, styled outcome leaves |
| Metrics / data report | Charts (SVG) + stat cards + callouts | Bar/line/sparkline, KPI callout boxes, colour-coded status |
| Codebase map | Spatial file/module layout | Size encoding, complexity indicators, connection lines |
| Debugging trace | Sequential flow with data at each hop | Service nodes, request/response data, timing indicators |
| Impact analysis | Ripple diagram from change point | Severity colour coding, affected component cards |
| Onboarding walkthrough | Step-by-step guide with progress | Progress indicator, collapsible detail, "you are here" marker |
| Incident timeline | Annotated timeline with severity bands | Time axis, action/event markers, impact zones, key decisions |
| Migration plan | Before/after with transformation steps | Dual-state diagram, numbered migration steps, status indicators |
| Dependency graph | Interactive node graph | Clickable nodes, highlight dependents/dependencies on selection |
| Knowledge graph | Concept nodes with labelled relationships | Cluster by domain, hover for definitions, filter by category |
| Config/schema comparison | Side-by-side with highlighted diffs | Matched sections, added/removed/changed indicators, annotations |
| API surface | Grouped endpoint cards | Method badges, expandable request/response, search/filter |

### Choosing rendering approaches

- **SVG**: Node-edge diagrams, flow charts, relationship diagrams, anything with connecting lines or arrows. Scales cleanly, handles positioned elements well.
- **HTML/CSS (Grid/Flexbox)**: Card layouts, timelines, comparison panels, stat dashboards, text-heavy content. Better for responsive layout.
- **Canvas**: Rarely needed. Only for very complex or performance-intensive visualisations (large force-directed graphs, animated particle effects).

## Interaction patterns

Use interaction to aid understanding. Each pattern has a specific purpose; don't add interaction for its own sake.

### Progressive disclosure (use often)

The most important pattern. Start with the overview, let readers drill into detail on what interests them. Collapsible sections, "click to expand" panels on diagram nodes, tabbed views for different perspectives.

### Hover for context (use when helpful)

Show additional information without requiring a click. Tooltips on diagram nodes, highlighting connected elements, data previews. Keep tooltips concise.

### Step-through animation (use selectively)

Reveal information in sequence to show causation, order, or build-up. Provide "Next/Previous" controls, optional auto-play with pause, and a progress indicator. Good for explaining algorithms, data transformations, or incident timelines.

### Filter and highlight (use for dense content)

Help users focus within information-dense displays. Category toggles, search with highlight, zoom to section. Essential when the visualisation has more than ~15 distinct elements.

### Navigation (use for long content)

If the visualisation has more than 3 sections, add a table of contents sidebar or sticky header navigation with anchor links. The user should never need to scroll blindly.

## Principles for good output

1. **Start with the overview.** The first thing someone sees should be the big picture. Detail comes second, on demand.

2. **Every element earns its place.** If a card, arrow, animation, or colour does not help someone understand the content, remove it.

3. **Colour communicates meaning.** Use it consistently: same colour = same category, intensity = importance, semantic colours (red/amber/green) = status. Never use colour randomly or purely for decoration.

4. **White space is a feature.** Give elements room to breathe. A visualisation that feels spacious is easier to parse than one that feels packed.

5. **Animations reveal, not decorate.** A fade-in on page load is pointless. An animation showing data transforming as it flows through a pipeline is valuable. If the animation would work just as well as a static layout, skip it.

6. **Verify both themes.** Before finishing, mentally check that the output works in both light and dark mode. Dark text on dark backgrounds is the most common failure.

7. **Title and context.** Every visualisation should have a clear title and a brief subtitle or description explaining what the viewer is looking at and why.

## Anti-patterns

- **Everything visible at once**: No progressive disclosure. The entire page is one giant flat diagram.
- **Gratuitous animation**: Bounce effects, fade-ins on every element, decorative transitions.
- **External dependencies**: Google Fonts, D3 from CDN, Font Awesome. The file must work offline.
- **Dark mode blindness**: Looks great in light mode, unreadable in dark.
- **No navigation**: A long page with no way to jump between sections.
- **Too much text in cards**: If most content is paragraphs, it is a styled document, not a visualisation. The visual structure should communicate most of the information; text provides context and detail.
- **Inconsistent styling**: Mixed shadow styles, hardcoded colours alongside custom properties, some sections interactive and others static with no reason for the difference.
- **Over-engineering**: Adding a full search system for a 5-node diagram. Match the complexity of the interaction to the complexity of the content.
