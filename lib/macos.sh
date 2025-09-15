# macOS-specific configuration and functions

export BASH_SILENCE_DEPRECATION_WARNING=1

PATH="/opt/homebrew/bin:$PATH"
PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
PATH="$(echo /Users/pawel.lipski/Library/Python/3.*/bin):$PATH"

alias pip=pip3
alias python=python3

function scr() {
  echo ~/Library/"Application Support"/JetBrains/IntelliJIdea202*/scratches/scratch_$1.*
}

function scrcat() {
  cat "$(scr $1)"
}

function screx() {
  (
    source ~/.virtuslab-commons/bazel-migration-utils.sh
    source "$(scr $1)"
  )
}
