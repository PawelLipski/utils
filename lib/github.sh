function update-github-token() {
  (( $# == 1 )) || { echo "usage: update-github-token <new-token>"; return 1; }
  token=$1
  echo "$token" > ~/.github-token
  yq --inplace '.hosts."github.com".oauth_token = "'$token'"' ~/.config/gh/config.yml
  yq --inplace '."github.com"[0].oauth_token = "'$token'"' ~/.config/hub
}

function list_open_prs_touching_directory() {
  if [ $# -eq 0 ]; then
    echo "Usage: list_open_prs_touching_directory <directory>"
    return 1
  fi

  local directory="$1"

  gh pr list --limit=2000 --json number,title,author,files,url \
    --jq '.[] | {number: .number, title: .title, author: .author.login, files: [.files[].path], url: .url}' \
    | while read -r pr; do
        local touched_files
        touched_files=$(echo "$pr" | jq -r --arg directory "$directory" '.files[] | select(startswith($directory + "/"))')
        if [ -n "$touched_files" ]; then
          local pr_number pr_title pr_author pr_url
          pr_number=$(echo "$pr" | jq -r '.number')
          pr_title=$(echo "$pr" | jq -r '.title')
          pr_author=$(echo "$pr" | jq -r '.author')
          pr_url=$(echo "$pr" | jq -r '.url')
          echo "PR #$pr_number by @$pr_author touches directory '$directory': $pr_title"
          echo "URL: $pr_url"
          echo "Touched files:"
          echo "$touched_files" | while read -r file; do
            echo "  - $file"
          done
          echo
        fi
      done
}

function open_last_pr_to_modify() {
  project=$(normalize_project_path $1)
  git log -1 --format="%(trailers:key=Github-Change-Url,valueonly)" $project | xargs open
}
