# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
else
  export CLICOLOR=YES
  # Change the directory color (first character) from the default blue (e) to cyan (g)
  # See https://ss64.com/osx/ls-env.html
  export LSCOLORS=gxfxcxdxbxegedabagacad
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [[ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
  fi
fi


# Shell options & vars

shopt -s cdspell
# Enable globstar if supported (requires Bash 4+)
if ((BASH_VERSINFO[0] >= 4)); then
  shopt -s globstar
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

CDPATH=".:$HOME"

# http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
HISTCONTROL=ignoredups:erasedups  # no duplicate entries
HISTSIZE=10000000                 # big big history
HISTFILESIZE=10000000             # big big history
shopt -s histappend               # append to history, don't overwrite it
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r"

export EDITOR=vim

PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'







# Misc aliases

function .. {
  for i in $(seq 1 ${1-1}); do
    cd ..;
  done
}

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias cdiff='colordiff -u'

function cat-latest-download() {
  cat ~/Downloads/"$(ls -thr ~/Downloads/ | tail -1)"
}

function check-links() {
  git ls-files \
  | xargs -i grep -ho "https://[^]')\" \`\\\\\$>,]*" "{}" \
  | sort -u \
  | xargs -l curl -Lfs -o/dev/null -w "%{http_code} %{url}\n" \
  | grep -v '^200'
}

alias colordiff='colordiff -u'

alias cp='cp -i'

alias deansi='sed -r "s/\x1b\[([0-9]{1,2}(;[0-9]{1,2})?)?m//g"'

# https://stackoverflow.com/a/15515152
function _exists() {
  # e.g. _exists *.kt
  [ -e "$1" ]
}

function extract_matching_file_from_url_zip() {
  local zip_url file_regex zip file_path file_count
  zip_url=$1
  file_regex=$2
  zip=$(mktemp)
  wget -q -O "$zip" "$zip_url"
  file_path=$(zipinfo -1 "$zip" | grep -E "$file_regex")
  if ! [[ $file_path ]]; then
    echo "No class whose path in jar matches $file_regex regex found" >&2
    return 1
  fi
  file_count=$(wc -l <<< "$file_path" | sed 's/^\s*//')
  if [[ $file_count -ne 1 ]]; then
    echo "Expected exactly 1 file whose path in zip matches $file_regex regex, found $file_count" >&2
    echo "$file_path" >&2
    return 1
  fi
  #echo "$file_path"
  unzip -p "$zip" "$file_path"
}

alias jqr='jq -r'

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alh'

alias less='less -r'

function mcd() {
  mkdir -p "$1" && cd "$1"
}

alias mv='mv -i'

alias py=python

alias reba='. ~/.bash_profile'

alias rm='rm -iv'

function scrabblify() {
	wget -qO- https://raw.githubusercontent.com/mkondratek/slack-scrabblifier/master/scrabblify.py | python - "$*" | xcopy && echo "Copied to clipboard"
}

alias v=vim

alias xcopy='xclip -selection clipboard'
alias xpaste='xclip -selection clipboard -o'

alias yqp='yq -P'

function vim() {
  if [[ $# = 1 ]]; then
    arg=${1#//}
    arg=${arg#a/}
    arg=${arg#b/}
    command vim "$arg"
  else
    command vim "$@"
  fi
}

function z() {
  zipinfo -1 "$1" | sort
}


function exclude() {
  comm -23 /dev/stdin "$1"
}

function add_prefix() {
  sed -E "s!^!$1!"
}

function drop_prefix() {
  sed -E "s!^$1!!"
}

function add_suffix() {
  sed -E "s!\$!$1!"
}

function drop_suffix() {
  sed -E "s!$1\$!!"
}

function prepend() {
  what=$1
  shift
  files=()
  if [ $# -gt 0 ]; then
      files=("$@")
  else
      while IFS= read -r line; do
          files+=("$line")
      done
  fi
  for file in "${files[@]}"; do
    { echo "$what"; cat $file; } | sponge $file
  done
}

# e.g. bazel query "allpaths(//:t1, //:t2)" --notool_deps --output graph | open_graph_svg
function open_graph_svg() {
  outdir=$(mktemp -d)
  dot -Tsvg > $outdir/graph.svg
  open $outdir/graph.svg
}

function modify_every_matching_file() {
  pattern="$1"
  for file in $(git ls-files "$pattern"); do
    echo "// $RANDOM" >> "$file"
  done
}

function _import() {
  source ~/.utils/lib/$1.sh
}

_import bazel
_import complete-alias
_import completion
_import docker
_import git
_import github
_import gradle
_import kubernetes
_import macos
_import projects
_import prompt
_import stats
_import unzip-jars-and-javap
