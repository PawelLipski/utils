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
shopt -s globstar  # requires Bash 4+; on Mac OS, you'll need to `brew install bash` and then `chsh`

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

# git aliases

alias g=git
alias ga='git add'
alias gaa='git add -A .'
alias gb='git branch'
alias gbr='git branch -r'
alias gcamend='git commit -a --amend --no-edit'
alias gcamendnv='gcamend --no-verify'
alias gcamendnvpf='gcamendnv && gpf'
alias gcamendpf='gcamend && gpf'
alias gcamendpff='gcamend && gpff'
alias gcamende='git commit -a --amend'
alias gcamendepf='gcamende && gpf'
alias gcl=' git clean -dn'
alias gclf='git clean -df'
alias gclx=' git clean -e .idea -e .sdkmanrc -dxn'
alias gclxf='git clean -e .idea -e .sdkmanrc -dxf'
alias gco='git checkout'
alias gcod='gco develop'
alias gcom='gco master'
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gdd="git diff -M develop"
alias gddx="git diff -M --stat develop"
alias gdhx='git diff -M --stat @'
alias gdm='git diff -M master'
alias gdno='git diff -M --name-only'
alias gdp='git diff -M @~'
alias gdpx='git diff -M --stat @~'
alias gdu='git diff -M @{upstream}'
alias gdw='git diff -M --word-diff'
alias gdx='git diff -M --stat'
alias gf='git fetch --prune'
alias ggr='git grep -n'
alias ggri='git grep -ni'
alias gl='git log'
alias gld='git log develop'
alias gll="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
alias glm='git log master'
alias glod='git log origin/develop'
alias glom='git log origin/master'
alias glp='git log --patch'
alias glpf='git log --pretty=fuller'
alias glu='git log @{upstream}'
alias gp='git push -u'
alias gpf='git push -u --force-with-lease --force-if-includes'
alias gpff='git push -u --force'
alias gpl='git pull --ff-only --prune'
alias gr='git remote'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias gre='git reset --soft'
alias grek='git reset --keep'
alias greku='git reset --keep @{upstream}'
alias	grl='git reflog --date=iso'
alias	grlp='git reflog --patch'
alias grs@='git restore -s @'
alias grs@~='git restore -s @~'
alias grsd='git restore -s develop'
alias grsm='git restore -s master'
alias gs='git status'
alias gsh='git show --pretty=fuller'
alias gshx='git show --stat'
alias gsu='git status -uno'  # don't show untracked files, speeds up operations on large repos
alias gx='git stash push'
alias gxa='git stash apply'
alias hcis='hub ci-status'
alias hps='hub pr show'

function g@ {
  git symbolic-ref --short --quiet HEAD 2>/dev/null \
    || { local tags; tags=$(git tag --points-at HEAD 2>/dev/null); [ -n "$tags" ] && paste -sd "," - <<< "$tags"; } \
    || git rev-parse --short HEAD 2>/dev/null
}

function gar {
  name=${1-$(basename "$(pwd)")}
  git archive --format=zip --output=../$name.zip --prefix=$name/ -v @
}

function gcm {
  if git diff --quiet HEAD; then
    git status
  else
    git commit -am "$*"
  fi
}

function gcmnv {
  if git diff --quiet HEAD; then
    git status
  else
    git commit --no-verify -am "$*"
  fi
}

function gcmlast {
  if git diff --quiet HEAD; then
    git status
  else
    old_message=$(git log -1 --format=%s)
    new_message=$(echo "$old_message" | sed 's/10th round/11th round/; s/9th round/10th round/; s/8th round/9th round/; s/7th round/8th round/; s/6th round/7th round/; s/5th round/6th round/; s/4th round/5th round/; s/3rd round/4th round/; s/2nd round/3rd round/; s/1st round/2nd round/')
    if [[ $new_message == "$old_message" ]]; then
      new_message="$old_message - 1st round of fixes"
    fi
    git commit --edit -am "$new_message"
  fi
}

function gcmp {
  gcm "$@" && gp
}

function gcmpf {
  gcm "$@" && gpf
}

function gcmpff {
  gcm "$@" && gpff
}

function gd() {
  if [[ $# -eq 0 ]]; then
    git diff -M @
  else
    git diff -M "$@"
  fi
}

function git-blamestat() {
  for dir in ${1-.}; do
    where=("--work-tree=$dir" "--git-dir=$dir/.git")
    git "${where[@]}" grep --no-recurse-submodules -Il '' \
    | grep -Eivx '.*\.(pem|pub|svg|xsd)|go\.sum|license|yarn\.lock' \
    | xargs -L1 git "${where[@]}" blame --line-porcelain \
    | grep -Po '(?<=^author-mail <).*(?=@)' \
    | sed 's/.*+//'
  done | sort | uniq -c | awk '{ print; sum += $1 } END { print sum }'
}

function git-remote-ssh-to-https-with-token() {
  local remote orig_url host org proj token url
  remote=${1-origin}
  orig_url=$(git remote get-url "$remote")
  if [[ $orig_url != *@*:*/* ]]; then
    echo "URL for $remote isn't an SSH URL, aborting"
    return 1
  fi
  host=${orig_url#*@}
  host=${host%:*}
  org=${orig_url#*:}
  org=${org%/*}
  proj=${orig_url#*/}
  proj=${proj%.*}

  token=$(gh auth token -h "$host") || return 1
  url=https://${token}@${host}/${org}/${proj}.git
  git remote set-url "$remote" "$url"
}

function gsmreku {
  git submodule foreach "{ git symbolic-ref --quiet HEAD >/dev/null || git checkout \"\$(git for-each-ref --format='%(refname:short)' --points-at=@ --count=1 refs/heads)\"; } && git fetch && git reset --keep @{upstream}"
}

function ls-prs() {
  hub pr list --format "%<(8)%i     %<(25)%au %<(50)%H -> %B%n"
}

function update-github-token() {
  (( $# == 1 )) || { echo "usage: update-github-token <new-token>"; return 1; }
  token=$1
  echo "$token" > ~/.github-token
  yq --inplace '.hosts."github.com".oauth_token = "'$token'"' ~/.config/gh/config.yml
  yq --inplace '."github.com"[0].oauth_token = "'$token'"' ~/.config/hub
}

# Docker aliases

alias d='docker'
alias dc='docker-compose'
alias dex='docker exec'
alias dim='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm'
alias drmi='docker rmi'


# Kubernetes aliases

function _kube_ps1() {
  if ! ${__display_kube_in_ps1-}; then
    echo "Using kube context $(kubectx --current)..."
  else
    __display_kube_in_ps1=true
  fi
}

alias a='_kube_ps1 && argocd'
alias h='_kube_ps1 && helm'
if [[ $ALIAS_K_AS_KUBECTL != false ]]; then
  alias k='_kube_ps1 && kubectl'
fi
alias kn='_kube_ps1 && kubens'
alias ku='_kube_ps1 && kubectl'
alias kx='_kube_ps1 && kubectx'
alias tf=terraform

PATH="$PATH:$HOME/utils/kubectl-plugins"


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


# PS1

function get_last_status_color() {
  s=$?
  [ $s -eq 0 ] && echo -ne "\033[01;32m" || echo -ne "\033[01;31m"
  exit $s # need to retain the status for get_last_status_content
}

function get_last_status_content() {
  s=$?
  [ $s -eq 0 ] && echo -n "➜" || echo -n "➜ ($s)"
}

function get_git_index_color() {
  [[ -f .git/skip-git-diff-in-ps1 ]] && echo -ne "\033[0m\033[01;33m" && return 2
  git diff --quiet HEAD &>/dev/null
  [ $? -eq 1 ] && echo -ne "\033[0m\033[01;33m" && return 1
  return 0
}

function get_git_index_char() {
  # Trick: using get_git_index_color's exit code to save another call to git diff
  case $? in
    1) echo -n " ✗" ;;
    2) echo -n " ?" ;;
  esac
}

function set_up_prompt() {
  local time='$(date +%H:%M)'
  local git_branch='$(cb=$(g@); [[ $cb ]] && echo " <git:$cb>")'
  local git_machete_anno='$(cb=$(g@); [[ $cb && -f .git/machete ]] && { echo -n " "; grep -Po "(?<=${cb} ).*" .git/machete; })'
  local git_index='$(get_git_index)'
  local prompt_tail=" \[\033[0m\033[01;35m\]\\$\[\033[0m\]"
  local kube_status='$(if [[ ${__display_kube_in_ps1-} ]]; then echo " \[\033[0m\033[1m\]$(kubectx -c):$(kubens -c)"; fi)'
  export PS1="\[\$(get_last_status_color)\]\$(get_last_status_content) \[\033[0m\033[1m\]${time} \[\033[01;36m\]\w\[\033[31m\]${git_branch}\[\033[0m\033[2m\]${git_machete_anno}\\[\$(get_git_index_color)\\]\$(get_git_index_char)${kube_status}${prompt_tail} "
  export PS4='$0.$LINENO: '
}
set_up_prompt


# Gradle

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


# Command completion

if [ -f /opt/complete_alias ]; then
	source /opt/complete_alias
	for cmd in a d dc g h k kn kx; do
	  complete -F _complete_alias $cmd
	done
fi

if command -v aws &>/dev/null && command -v aws_completer &>/dev/null; then
  complete -C aws_completer aws
fi

if [ -f ~/.git.completion.bash ]; then
  . ~/.git.completion.bash
  __git_complete g    __git_main
  __git_complete gco  _git_checkout
  __git_complete gd   _git_diff
  __git_complete ggr  _git_grep
  __git_complete ggri _git_grep
  __git_complete gl   _git_log
  __git_complete gp   _git_push
  __git_complete gpl  _git_pull
fi

if command -v gh &>/dev/null; then
  eval "$(gh completion -s bash)"
fi

if command -v git-machete &>/dev/null; then
  eval "$(GIT_MACHETE_MEASURE_COMMAND_TIME=false git machete completion bash)"
fi

if command -v helm &>/dev/null; then
  eval "$(helm completion bash)"
fi

if command -v kind &>/dev/null; then
  source <(kind completion bash)
fi

if command -v kubectl &>/dev/null; then
  eval "$(kubectl completion bash)"
fi

if command -v kubectx &>/dev/null && [ -f /opt/kubectx/completion/kubectx.bash ]; then
  . /opt/kubectx/completion/kubectx.bash
fi

if command -v kubens &>/dev/null && [ -f /opt/kubectx/completion/kubens.bash ]; then
  . /opt/kubectx/completion/kubens.bash
fi


# sdkman

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# Mac OS specific

export BASH_SILENCE_DEPRECATION_WARNING=1

## iterm2

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
