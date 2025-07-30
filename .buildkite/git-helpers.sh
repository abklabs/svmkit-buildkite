#!/usr/bin/env bash
# git-clone-branch <repo-url> <dest-dir> [branch]
git-clone-branch() {
  local repo_url="$1"
  local dest_dir="$2"
  local branch="${3:-}"
  if [[ $# -lt 2 ]]; then
    echo "Usage: git-clone-branch <repo-url> <dest-dir> [branch]" >&2
    return 1
  fi
  
  # If branch not explicitly provided, try $REPO_BRANCH
  if [[ -z "$branch" ]]; then
    local repo_name
    repo_name=$(basename -s .git "$repo_url" | tr '[:lower:]' '[:upper:]' | tr -c 'A-Z0-9' '_')
    # remove trailing '_'
    repo_name="${repo_name%"${repo_name##*[!_]}"}"    
    local env_var="${repo_name}_BRANCH"
    branch="${!env_var:-}"
    [[ -n "$branch" ]] && echo "Using branch '$branch' from \$$env_var"
  fi
  
  echo "Cloning $repo_url into $dest_dir..."
  if [[ -d "$dest_dir/.git" ]]; then
    echo "Directory '$dest_dir' already contains a Git repo. Skipping clone."
  else
    git clone "$repo_url" "$dest_dir"
  fi
  
  if [[ -n "$branch" ]]; then
    echo "Checking out branch '$branch' in $dest_dir..."
    git -C "$dest_dir" checkout "$branch"
  fi
}

buildkite-git-summary() {
  local failed=0
  echo "--- Git Branch Summary"
  for full_url in "$@"; do
    repo_name=$(basename "$full_url" .git)

    # Normalize repo name to uppercase with underscores: e.g., tooling → TOOLING_BRANCH
    var_name="$(echo "$repo_name" | tr '[:lower:]-' '[:upper:]_')_BRANCH"
    branch="${!var_name:-main}"

    # Check if repo exists
    if ! git ls-remote --exit-code --quiet "$full_url" &>/dev/null; then
      echo ":x: Repo not found: $full_url"
      failed=1
      continue
    fi

    # Check if branch exists
    if ! git ls-remote --exit-code --heads "$full_url" "$branch" &>/dev/null; then
      echo ":x: Branch '$branch' not found in $repo_name"
      failed=1
      continue
    fi
    
    echo ":white_check_mark: $repo_name → $branch"
  done
  echo "^^^ +++"
  return $failed
}

