---
name: datetime
description: Get current date/time using bash commands. Never assume - always fetch.
---

# Datetime Skill

**NEVER assume the current date or time.** Always use bash commands to fetch it.

## Common Formats

### Full Timestamp (ISO-like)
```bash
date +"%Y-%m-%d %H:%M:%S"
# Output: 2025-12-17 16:30:45
```

### Date Only
```bash
date +"%Y-%m-%d"
# Output: 2025-12-17
```

### Time Only
```bash
date +"%H:%M:%S"
# Output: 16:30:45
```

### ISO 8601 (UTC)
```bash
date -u +"%Y-%m-%dT%H:%M:%SZ"
# Output: 2025-12-17T16:30:45Z
```

### Unix Timestamp
```bash
date +%s
# Output: 1734451845
```

### Human-Readable
```bash
date +"%d %B %Y"
# Output: 17 December 2025
```

## Date Arithmetic

### Yesterday
```bash
date -v-1d +"%Y-%m-%d"
# Output: 2025-12-16
```

### N Days Ago
```bash
date -v-7d +"%Y-%m-%d"
# Output: 2025-12-10 (7 days ago)
```

### Start of Month
```bash
date -v1d +"%Y-%m-%d"
# Output: 2025-12-01
```

### Last Month
```bash
date -v-1m +"%Y-%m"
# Output: 2025-11
```

## Comparison / Calculation

### Days Between Dates
```bash
echo $(( ($(date -jf "%Y-%m-%d" "2025-12-17" +%s) - $(date -jf "%Y-%m-%d" "2025-12-10" +%s)) / 86400 ))
# Output: 7
```

### Is Date Older Than N Days?
```bash
# Check if a date is older than 30 days
target_date="2025-11-01"
days_ago=$(( ($(date +%s) - $(date -jf "%Y-%m-%d" "$target_date" +%s)) / 86400 ))
echo $days_ago
```

## Format Specifiers Reference

| Specifier | Meaning | Example |
|-----------|---------|---------|
| `%Y` | Year (4 digit) | 2025 |
| `%m` | Month (01-12) | 12 |
| `%d` | Day (01-31) | 17 |
| `%H` | Hour (00-23) | 16 |
| `%M` | Minute (00-59) | 30 |
| `%S` | Second (00-59) | 45 |
| `%B` | Month name | December |
| `%A` | Day name | Wednesday |
| `%s` | Unix timestamp | 1734451845 |
| `%Z` | Timezone | GMT |

## Important Rules

1. **Always fetch, never assume** - Even if you think you know the date
2. **Use appropriate format** - ISO for logs, human-readable for display
3. **Consider timezone** - Use `-u` flag for UTC when needed
4. **macOS uses BSD date** - Syntax differs from GNU date (Linux)

## Quick Reference

| Need | Command |
|------|---------|
| Current datetime | `date +"%Y-%m-%d %H:%M:%S"` |
| Current date | `date +"%Y-%m-%d"` |
| Current time | `date +"%H:%M:%S"` |
| Yesterday | `date -v-1d +"%Y-%m-%d"` |
| UTC timestamp | `date -u +"%Y-%m-%dT%H:%M:%SZ"` |
