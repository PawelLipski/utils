# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Shell options & vars

shopt -s autocd cdspell

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
HISTCONTROL=ignoredups:erasedups  # no duplicate entries
HISTSIZE=10000000                 # big big history
HISTFILESIZE=10000000             # big big history
shopt -s histappend               # append to history, don't overwrite it
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r"

export CDPATH='.:~'

export EDITOR=vim

PATH="$PATH:$HOME/.local/bin"


# git aliases

alias g=git
alias ga='git add'
alias gaa='git add -A .'
alias gb='git branch'
alias gbr='git branch -r'
alias gcamend='git commit -a --amend --no-edit'
alias gcamendnv='git commit -a --amend --no-edit --no-verify'
alias gcamendnvpf='gcamendnv && gpf'
alias gcamendpf='gcamend && gpf'
alias gcamende='git commit -a --amend'
alias gco='git checkout'
alias gcod='gco develop || gco dev'
alias gcom='gco master || gco main'
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gd='git diff -M'
alias gdd="git diff -M develop"
alias gddx="git diff --stat develop"
alias gdh='git diff -M @'
alias gdhx='git diff --stat @'
alias gdm='git diff -M master'
alias gdno='git diff --name-only'
alias gdp='git diff -M @~'
alias gdpx='git diff --stat @~'
alias gdu='git diff -M @{upstream}'
alias gdw='git diff --word-diff'
alias gdx='git diff --stat'
alias gf='git fetch'
alias ggr='git grep -n'
alias gl='git log'
alias gld='git log develop'
alias gll="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
alias glm='git log master'
alias glod='git log origin/develop'
alias glom='git log origin/master'
alias glpf='git log --pretty=fuller'
alias gp='git push -u'
alias gpf='git push -u --force-with-lease --force-if-includes'
alias gpl='git pull --ff-only'
alias gr='git remote'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias gre='git reset'
alias greku='git reset --keep @{upstream}'
alias gs='git status'
alias gsh='git show'
alias gshp='git show @~'
alias gshx='git show --stat'
alias gsm='git submodule'
alias gsms='git submodule status'
alias gsmu='git submodule update'
alias gx='git stash'
alias gxa='git stash apply'
alias hcis='hub ci-status'

function blamestat {
  for dir in ${1-.}; do
    where="--work-tree=$dir --git-dir=$dir/.git"
    git $where grep --no-recurse-submodules -Il '' | egrep -iv '\.(pem|pub|xsd)$|license|yarn.lock' | xargs -L1 git $where blame --line-porcelain | grep -Po '(?<=^author-mail <).*(?=@)' | sed 's/.*+//'
  done | sort | uniq -c | awk '{ print; sum += $1 } END { print sum }'
}

function g@ {
  git symbolic-ref --short --quiet HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

function gar {
  name=${1-$(basename `pwd`)}
  git archive --format=zip --output=../$name.zip --prefix=$name/ -v @
}

function gcm {
  if git diff-index --quiet HEAD; then
    git status
  else
    git commit -am "$*"
  fi
}

function gcmnv {
  if git diff-index --quiet HEAD; then
    git status
  else
    git commit --no-verify -am "$*"
  fi
}

function gcmlast {
  if git diff-index --quiet HEAD; then
    git status
  else
    git commit --edit -am "$(git log -1 --format=%s | sed 's/8th round/9th round/; s/7th round/8th round/; s/6th round/7th round/; s/5th round/6th round/; s/4th round/5th round/; s/3rd round/4th round/; s/2nd round/3rd round/; s/1st round/2nd round/; s/0th round/1st round/')"
  fi
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
alias k='_kube_ps1 && kubectl'
alias kn='_kube_ps1 && kubens'
alias kx='_kube_ps1 && kubectx'
alias tf=terraform

PATH="$PATH:$HOME/utils/kubectl-plugins"

# Misc aliases

function .. {
  for i in `seq 1 ${1-1}`; do
    cd ..;
  done
}

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

function cdiff() {
  colordiff -u "$@" | less -r
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

alias jqr='jq -r'

alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CF'

alias mv='mv -i'

alias py=python

alias reba='. ~/.bashrc'

alias rm='rm -iv'

function scrabblify() {
	wget -qO- https://raw.githubusercontent.com/mkondratek/slack-scrabblifier/master/scrabblify.py | python - "$*" | xcopy && echo "Copied to clipboard"
}

alias vimba='vim ~/.bashrc; reba'

alias xcopy='xclip -selection clipboard'
alias xpaste='xclip -selection clipboard -o'

alias yqp='yq -P'

# PS1

get_last_status_color() {
  s=$?
  [ $s -eq 0 ] && echo -ne "\033[01;32m" || echo -ne "\033[01;31m"
  exit $s # need to retain the status for get_last_status_content
}

get_last_status_content() {
  s=$?
  [ $s -eq 0 ] && echo -n ➜ || echo -n "➜ ($s)"
}

get_git_index_color() {
  git diff-index --quiet HEAD &>/dev/null
  [ $? -eq 1 ] && echo -ne "\033[0m\033[01;33m" && exit 1
  exit 0
}

get_git_index_char() {
  # Trick: using get_git_index_color's exit code to save another call to git diff-index
  [ $? -eq 1 ] && echo -n ✗
}

set_up_prompt() {
  local time='$(date +%H:%M)'
  local git_branch='$(cb=$(g@); [[ $cb ]] && echo " $cb")'
  local git_machete_anno='$(cb=$(g@); [[ $cb ]] && grep -Po "(?<=${cb}) .*" $([[ -f .git/machete ]] && echo .git/machete || git machete file))'
  local git_index='$(get_git_index)'
  local prompt_tail=" \[\033[0m\033[01;35m\]\\$\[\033[0m\]"
  local kube_status='$(if [[ ${__display_kube_in_ps1-} ]]; then echo " \[\033[0m\033[1m\]$(kubectx -c):$(kubens -c)"; fi)'
  export PS1="\[\$(get_last_status_color)\]\$(get_last_status_content) \[\033[0m\033[1m\]${time} \[\033[01;36m\]\w\[\033[31m\]${git_branch}\[\033[0m\033[2m\]${git_machete_anno}\\[\$(get_git_index_color)\\]\$(get_git_index_char)${kube_status}${prompt_tail} "
}
set_up_prompt

# Java aliases

alias j=./gradlew

# Command completion

## alias completion

if [ -f /opt/complete_alias ]; then
	source /opt/complete_alias
	for cmd in a d dc g h j k kn kx; do
	  complete -F _complete_alias $cmd
	done
fi

## argocd completion

if command -v argocd &>/dev/null; then
  source <(argocd completion bash)
fi

## aws completion

if command -v aws &>/dev/null && command -v aws_completer &>/dev/null; then
  complete -C aws_completer aws
fi

## helm completion

if command -v helm &>/dev/null; then
  eval "$(helm completion bash)"
fi

## kind completion

if command -v argocd &>/dev/null; then
  source <(kind completion bash)
fi

## kubectl completion

if command -v kubectl &>/dev/null; then
  eval "$(kubectl completion bash)"
fi

## kubectx completion
if command -v kubectx &>/dev/null && [ -f /opt/kubectx/completion/kubectx.bash ]; then
  . /opt/kubectx/completion/kubectx.bash
fi

## kubens completion
if command -v kubens &>/dev/null && [ -f /opt/kubectx/completion/kubens.bash ]; then
  . /opt/kubectx/completion/kubens.bash
fi

# op (1Password CLI) completion
if command -v op &>/dev/null; then
  eval "$(op completion bash)"
fi
