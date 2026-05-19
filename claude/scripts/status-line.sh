#!/usr/bin/env bash
# Claude Code status line: context bar + git branch + PR link

input=$(cat)

# --- Context bar ---
# Compute effective % from raw tokens (input + output + cache), not just used_percentage
# used_percentage only counts input tokens, missing output which also consumes the window
read input_tok output_tok cache_create cache_read ctx_size < <(echo "$input" | jq -r '[
  .context_window.current_usage.input_tokens // 0,
  .context_window.current_usage.output_tokens // 0,
  .context_window.current_usage.cache_creation_input_tokens // 0,
  .context_window.current_usage.cache_read_input_tokens // 0,
  .context_window.context_window_size // 200000
] | @tsv')

total=$((input_tok + output_tok + cache_create + cache_read))
pct=$((total * 100 / ctx_size))

# Clamp 0-100
(( pct < 0 )) && pct=0 || true
(( pct > 100 )) && pct=100 || true

# Bar dimensions
w=10
f=$((pct * w / 100))
e=$((w - f))

# Colour by usage level
if (( pct < 50 )); then
  c='\033[32m'   # green
elif (( pct < 75 )); then
  c='\033[33m'   # yellow
else
  c='\033[31m'   # red
fi
r='\033[0m'
d='\033[90m'

# Build visual bar (printf repeats the char once per seq argument)
fb=""; (( f > 0 )) && fb=$(printf '█%.0s' $(seq 1 $f)) || true
eb=""; (( e > 0 )) && eb=$(printf '░%.0s' $(seq 1 $e)) || true
bar="${c}${fb}${d}${eb}${r} ${c}${pct}%${r}"

# --- Model ---
model_name=$(echo "$input" | jq -r '.model.display_name // "unknown"' | sed 's/ ([0-9]*[KMG] context)$//')
model_lower=$(echo "$model_name" | tr '[:upper:]' '[:lower:]')
case "$model_lower" in
  *opus*)   model_icon='♬'; mc='\033[94m' ;;   # beamed sixteenths, pastel blue
  *sonnet*) model_icon='♪'; mc='\033[95m' ;;   # eighth note, pastel magenta
  *haiku*)  model_icon='♩'; mc='\033[92m' ;;   # quarter note, pastel green
  *)        model_icon='?'; mc='\033[37m' ;;
esac

# Format context window size as human-readable (e.g. 200000 → 200K, 1000000 → 1M)
if (( ctx_size >= 1000000 )); then
  ctx_label="$((ctx_size / 1000000))M"
elif (( ctx_size >= 1000 )); then
  ctx_label="$((ctx_size / 1000))K"
else
  ctx_label="${ctx_size}"
fi

model_label="${mc}${model_icon}${r} ${model_name} ${d}(${ctx_label})${r}"

# --- Git info ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "???")

# Truncate long branch names: 11 chars left ... 25 chars right
max_branch=39
if [ ${#branch} -gt $max_branch ]; then
  branch="${branch:0:11}...${branch: -25}"
fi

# --- PR info ---
pr_url=$(cd "$cwd" && gh pr view --json url -q .url 2>/dev/null || echo "")
if [ -n "$pr_url" ]; then
  pr_num=$(echo "$pr_url" | sed 's|.*/pull/||')
  pr_slug=$(echo "$pr_url" | sed 's|https://github.com/||; s|/pull/.*||')
  pr_label="${pr_slug}#${pr_num}"
  # OSC 8 clickable hyperlink for iTerm2
  pr_display="\033]8;;${pr_url}\007${pr_label}\033]8;;\007"
else
  pr_display="no PR"
fi

echo -e "${model_label} ${bar} | ${branch} | ${pr_display}"
