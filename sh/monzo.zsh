# Monzo Specific Shell Configuration

# Monzo git configuration
alias gitconfigmonzo='git config user.name "Bruno Campos" && git config user.email "brunocampos@monzo.com" && git config user.signingkey 7C867AAC0E30CEDD'

# Monzo Analytics/dbt sourcing
[ -f $HOME/src/github.com/monzo/analytics/dbt/misc/shell/source.sh ] && source $HOME/src/github.com/monzo/analytics/dbt/misc/shell/source.sh

# Monzo specific terminal commands

# To capture an image of your terminal command output in dbt-monzo shell
terminal_capture() {
    # Check if termshot is installed
    if ! command -v termshot &> /dev/null; then
        echo "❌ termshot is not installed"
        echo "Install it with: brew install homeport/tap/termshot"
        return 1
    fi

    # Check if command was provided
    if [ -z "$1" ]; then
        echo "Usage: terminal_capture <command>"
        echo "Example: terminal_capture adbt run -s my_model"
        return 1
    fi
    
    # Find the dbt-monzo-shell container ID
    CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
    
    # Check if container was found
    if [ -z "$CONTAINER_ID" ]; then
        echo "Error: No dbt-monzo-shell container found running"
        echo "Run 'dbt-monzo' first to start the container"
        return 1
    fi
    
    # Generate filename with timestamp
    FILENAME="termshot_output_$(date +%Y%m%d_%H%M%S).png"
    
    echo "📸 Found container: $CONTAINER_ID"
    echo "🏃 Running: $@"
    echo "---"
    
    # Run termshot and save to file
    termshot --filename "$FILENAME" -- "docker exec -t $CONTAINER_ID $@ 2>&1"
    
    # Copy the PNG to clipboard
    osascript -e "set the clipboard to (read (POSIX file \"$PWD/$FILENAME\") as «class PNGf»)"
    
    echo "✅ Screenshot saved to: $FILENAME"
    echo "📋 Copied to clipboard!"
}

# Alias for even quicker access
alias tcap='terminal_capture'

# run dbt-monzo shell commands from any terminal
monzo() {
  CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
  if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dbt-monzo-shell container found running"
    echo "Run 'docker run' command to start the container"
    return 1
  fi

  # Check if running in an interactive terminal
  if [ -t 1 ] && [ -t 0 ]; then
    # Interactive mode (humans)
    docker exec -it "$CONTAINER_ID" "$@"
  else
    # Non-interactive mode (Claude Code, scripts, etc.)
    docker exec "$CONTAINER_ID" "$@"
  fi
}

# run modelgen commands from any terminal
modelgen() {
  CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
  if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dbt-monzo-shell container found running"
    echo "Run 'dbt-monzo' first to start the container"
    return 1
  fi

  # Check if running in an interactive terminal
  if [ -t 1 ] && [ -t 0 ]; then
    docker exec -it "$CONTAINER_ID" modelgen "$@"
  else
    docker exec "$CONTAINER_ID" modelgen "$@"
  fi
}

# run adbt commands from any terminal
adbt() {
  CONTAINER_ID=$(docker ps --format "{{.ID}}" --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master" | head -1)
  if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No dbt-monzo-shell container found running"
    echo "Run 'dbt-monzo' first to start the container"
    return 1
  fi

  # Check if running in an interactive terminal
  if [ -t 1 ] && [ -t 0 ]; then
    docker exec -it "$CONTAINER_ID" adbt "$@"
  else
    docker exec "$CONTAINER_ID" adbt "$@"
  fi
}

# For adbt target output
copy_target() {
  local dest_name="${1:-dbt_target}"
  local dest_path="$HOME/src/github.com/monzo/analytics/dbt/$dest_name"

  container_id=$(docker ps -q --filter "ancestor=us-central1-docker.pkg.dev/monzo-build/dbt-monzo-shell/dbt-monzo-shell:master")

  if [[ -z "$container_id" ]]; then
    echo "No running dbt container found."
    return 1
  fi

  tmp_target=$(docker exec "$container_id" sh -c 'find /tmp/ -type d -path "*/target" -print0 | xargs -0 stat --format "%Y %n" | sort -nr | head -1 | cut -d" " -f2-')

  if [[ -z "$tmp_target" ]]; then
    echo "Could not find a target folder in /tmp/"
    return 1
  fi

  tmp_root=$(dirname "$tmp_target")

  docker cp "${container_id}:${tmp_root}" ./_tmp_target_copy

  if [[ ! -d "./_tmp_target_copy" ]]; then
    echo "Copy failed — _tmp_target_copy does not exist."
    return 1
  fi

  real_target_path=$(find ./_tmp_target_copy -type d -name target | head -n 1)

  if [[ -z "$real_target_path" ]]; then
    echo "Could not find the target folder inside _tmp_target_copy."
    rm -rf ./_tmp_target_copy
    return 1
  fi

  mkdir -p "$(dirname "$dest_path")"
  mv "$real_target_path" "$dest_path"

  rm -rf ./_tmp_target_copy
}

# Monzo starter pack
[ -f ${GOPATH}/src/github.com/monzo/starter-pack/zshrc ] && source ${GOPATH}/src/github.com/monzo/starter-pack/zshrc
