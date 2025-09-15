# Gradle-related functions and aliases

function j() {
  dir=$PWD
  until [[ -f "$dir/gradlew" ]] || [[ $dir = "/" ]]; do
    dir=$(realpath "$dir/..")
  done
  if [[ $dir != "/" ]]; then
    if [[ $# -eq 1 ]]; then
      "$dir/gradlew" "${1//\//:}"
    else
      "$dir/gradlew" "$@"
    fi
  else
    echo "gradlew not found in any directory up to filesystem root" >&2
    return 1
  fi
}

alias ji='j --info'
alias jb='j build'
