---
name: documentation
description: Style guide for writing engaging, visually appealing documentation with emojis, tables, diagrams, and proper structure. Always outputs to markdown files.
---

# 📝 Documentation Writing Skill

This skill provides guidance on creating engaging, visually appealing documentation that is easy to read and navigate. Documentation should be informative but never boring.

## 🎯 Core Principles

1. **Always output to a markdown file** — Terminal output is unreliable for copying; write to `.md` files
2. **Make it visually engaging** — Use formatting to break up walls of text
3. **Use emojis purposefully** — Section headers, callouts, and visual markers (not excessive)
4. **Include diagrams when helpful** — Use the `mermaid` skill for flowcharts and diagrams
5. **Structure for scanning** — Headers, bullets, tables, and whitespace
6. **Friendly professional tone** — Casual but competent (unless asked otherwise)

## 📁 File Output

**Always write documentation to a file.** The location doesn't matter much — just provide the path and user can `pbcopy` if needed.

```bash
# Get timestamp for unique filenames
date +"%Y%m%d_%H%M%S"
```

**Naming patterns:**
- `<topic>_guide.md`
- `<topic>_documentation.md`
- `<topic>_<timestamp>.md`

**After writing:** Tell the user the path so they can access it.

## 🎨 Emoji Usage

Emojis add visual interest and help readers scan documents. Use them strategically, not excessively.

### ✅ DO Use Emojis For

| Purpose | Examples |
|---------|----------|
| **Section headers** | `## 🚀 Getting Started`, `## ⚙️ Configuration` |
| **Key callouts** | `⚠️ Warning:`, `💡 Tip:`, `📌 Note:` |
| **Status indicators** | `✅ Complete`, `❌ Failed`, `🔄 In Progress` |
| **Category markers** | `📁 Files`, `🔧 Tools`, `📊 Data` |

### ❌ DON'T Use Emojis

- In every sentence
- Multiple emojis stacked together
- In code blocks or technical references
- When they add no value

### Emoji Reference

| Category | Emojis |
|----------|--------|
| **Sections** | 📋 📝 📚 📖 🗂️ |
| **Actions** | 🚀 ▶️ 🔄 ⚡ 🎯 |
| **Status** | ✅ ❌ ⚠️ 🔴 🟢 🟡 |
| **Info** | 💡 📌 ℹ️ 🔍 👀 |
| **Technical** | ⚙️ 🔧 🛠️ 🔌 💻 |
| **Data** | 📊 📈 📉 🗄️ 💾 |
| **People** | 👤 👥 🧑‍💻 |
| **Time** | ⏰ 📅 🕐 |
| **Warning** | ⚠️ 🚨 ⛔ 🔒 |
| **Success** | ✨ 🎉 🏆 ⭐ |

## 📊 Tables

Tables are excellent for:
- Comparing options
- Reference data
- Command summaries
- Configuration options

### When to Use Tables

| Scenario | Use Table? |
|----------|------------|
| Comparing 3+ items with multiple attributes | ✅ Yes |
| List of commands with descriptions | ✅ Yes |
| Key-value pairs (settings, config) | ✅ Yes |
| Sequential steps | ❌ No (use numbered list) |
| Single item with many details | ❌ No (use sections) |

### Table Formatting

```markdown
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
```

**Tips:**
- Keep columns concise
- Align content for readability
- Use code formatting for commands: \`command\`
- Use emojis for status: ✅ / ❌

## 📈 Diagrams

**Use the `mermaid` skill** for creating diagrams. Diagrams help when:
- Explaining data flow or architecture
- Showing relationships between components
- Illustrating processes or workflows
- Comparing structures

### When to Include Diagrams

| Content Type | Diagram Type |
|--------------|--------------|
| System architecture | Flowchart |
| Data pipelines | Flowchart with subgraphs |
| Entity relationships | ERD |
| Process workflows | Flowchart |
| Decision trees | Flowchart with decisions |
| State transitions | State diagram |

### Diagram Placement

- Place diagrams near the content they illustrate
- Add a brief caption or explanation below
- Reference the diagram in surrounding text

## 📝 Document Structure

### Standard Template

```markdown
# 📚 [Document Title]

Brief introduction explaining what this document covers and who it's for.

## 🎯 Overview / Purpose

What this is and why it matters.

## 🚀 Getting Started

Quick start or prerequisites.

## 📋 Main Content

### Section 1
Content with appropriate formatting...

### Section 2
More content...

## 📊 Reference

Tables, diagrams, or reference material.

## 💡 Tips / Best Practices

Optional but often valuable.

## ❓ FAQ / Troubleshooting

Common questions or issues (if applicable).

## 🔗 Related Resources

Links to related documentation.
```

### Section Header Emojis

| Section Type | Suggested Emoji |
|--------------|-----------------|
| Overview / Purpose | 🎯 |
| Getting Started | 🚀 |
| Installation / Setup | ⚙️ |
| Configuration | 🔧 |
| Usage / How To | 📖 |
| Reference | 📋 |
| Examples | 💻 |
| Tips | 💡 |
| Warnings | ⚠️ |
| Troubleshooting | 🔍 |
| FAQ | ❓ |
| Related | 🔗 |
| Summary | 📝 |

## ✍️ Writing Style

### Tone

- **Friendly but professional** — Like explaining to a colleague
- **Clear and direct** — Don't waffle
- **Helpful** — Anticipate questions
- **Not patronising** — Assume intelligence

### Formatting for Readability

| Instead of... | Do this... |
|---------------|------------|
| Long paragraphs | Short paragraphs (2-4 sentences max) |
| Dense text | Bullet points and lists |
| Repetitive explanations | Tables for comparison |
| Abstract descriptions | Concrete examples |
| Wall of commands | Code blocks with comments |

### Callout Boxes

Use blockquotes with emojis for emphasis:

```markdown
> 💡 **Tip:** This is a helpful tip that adds value.

> ⚠️ **Warning:** This is important and could cause issues.

> 📌 **Note:** This is additional context worth knowing.

> ✨ **Pro tip:** This is an advanced technique.
```

### Code Examples

Always use fenced code blocks with language hints:

```markdown
\`\`\`bash
# Comment explaining what this does
command --with flags
\`\`\`
```

Add brief explanations before or after code blocks.

## 📋 Checklists

Use checklists for:
- Step-by-step guides
- Requirements
- Review criteria

```markdown
- [ ] First step
- [ ] Second step
- [x] Completed step
```

## 🎨 Visual Hierarchy

Create clear visual hierarchy:

1. **H1** — Document title only (one per doc)
2. **H2** — Major sections (with emojis)
3. **H3** — Subsections
4. **H4** — Minor divisions (use sparingly)
5. **Bold** — Key terms, important points
6. **Code** — Commands, file names, technical terms
7. **Italic** — Emphasis, definitions

## ✅ Quality Checklist

Before finishing documentation, verify:

- [ ] Written to a `.md` file
- [ ] Clear title with emoji
- [ ] Logical section structure
- [ ] Emojis on major headers (not excessive)
- [ ] Tables where comparison is needed
- [ ] Diagrams for complex flows (if applicable)
- [ ] Code examples are formatted and explained
- [ ] No walls of text — broken into digestible chunks
- [ ] British English spelling (colour, organisation, etc.)
- [ ] Tone is friendly but professional

## 🚫 Common Mistakes

### ❌ DON'T

- Write everything as paragraphs
- Skip section headers
- Use emojis in every line 🎉🎊🥳
- Create tables with only 2 columns and 2 rows
- Add diagrams that don't clarify anything
- Use overly formal or stiff language
- Forget to tell user where the file was saved

### ✅ DO

- Break content into scannable sections
- Use the right format for the content type
- Add emojis purposefully for visual navigation
- Include examples and code samples
- Reference related documentation
- Provide the file path after writing

## 📎 Quick Reference

| Element | When to Use |
|---------|-------------|
| **Emoji headers** | All H2 sections |
| **Tables** | Comparing 3+ items, reference data |
| **Diagrams** | Architecture, flows, relationships |
| **Bullets** | Lists of items, features, options |
| **Numbers** | Sequential steps, ordered processes |
| **Code blocks** | Commands, configs, examples |
| **Callouts** | Tips, warnings, important notes |
| **Checklists** | Action items, requirements |

---

**Remember:** Documentation should be helpful AND pleasant to read. If it looks like a boring manual, add more structure and visual elements. If it looks like a children's book, tone down the emojis.
