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
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


# Shell options & vars

shopt -s autocd cdspell dotglob

# http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
HISTCONTROL=ignoredups:erasedups  # no duplicate entries
HISTSIZE=10000000                   # big big history
HISTFILESIZE=10000000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r"

export CDPATH='.:~'

export EDITOR=vim

PATH="$PATH:$HOME/.local/bin"


# git aliases

alias @='git machete'
alias @a='git machete add'
alias @D='git machete discover'
alias @d='git machete diff'
alias @e='git machete edit'
alias @g='git machete go'
alias @gd='git machete go down'
alias @gf='git machete go first'
alias @gl='git machete go last'
alias @gn='git machete go next'
alias @gp='git machete go prev'
alias @gu='git machete go up'
alias @r='git machete reapply'
alias @s='git machete status'
alias @sl='git machete status -l'
alias @sL='git machete status -L'
alias @t='git machete traverse'
alias @tw='git machete traverse -w'
alias @tW='git machete traverse -W'
alias @u='git machete update'
alias ga='git add'
alias gaa='git add -A .'
alias gb='git branch'
alias gbr='git branch -r'
alias gcamend='git commit -a --amend --no-edit'
alias gcamendnv='git commit -a --amend --no-edit --no-verify'
alias gcamendnvpf='gcamendnv && gpf'
alias gcamendpf='gcamend && gpf'
alias gcamende='git commit -a --amend'
alias gco='git checkout --recurse-submodules'
alias gcod='gco develop'
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
alias gm='git merge --ff-only'
alias gp='git push -u 2>&1'
alias gpf='git push -u --force-with-lease 2>&1'
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
        git $where grep --no-recurse-submodules -Il '' | egrep -iv '\.(pem|pub|xsd)$|license|yarn.lock' | xargs -L1 git $where blame --line-porcelain | grep -Po '(?<=^author-mail <).*(?=@)'
    done | sort | uniq -c | awk '{ print; sum += $1 } END { print sum }'
}

function cdiff {
    colordiff -u "$@" | less -r
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
        git commit -am "$(git log -1 --format=%s | sed 's/5th round/6th round/; s/4th round/5th round/; s/3rd round/4th round/; s/2nd round/3rd round/; s/1st round/2nd round/')" --edit
    fi
}

function gsmreku {
    git submodule foreach "{ git symbolic-ref --quiet HEAD >/dev/null || git checkout \"\$(git for-each-ref --format='%(refname:short)' --points-at=@ --count=1 refs/heads)\"; } && git fetch && git reset --keep @{upstream}"
}

function ls-prs() {
    hub pr list --format "%<(8)%i     %<(25)%au %<(50)%H -> %B%n"
}

function track-prs-bb() {
    input=$(cat)
    echo "$input"
    current=$(grep -Po '(?<=View pull request for ).*(?= => )' <<< "$input") || exit
    pr_upstream=$(grep -Po '(?<=View pull request for '$current' => ).*(?=:)' <<< "$input") || exit
    # TODO: it assumes the current branch is pushed
    machete_upstream=$(git machete show up 2>/dev/null) || exit
    if [[ "$machete_upstream" != "$pr_upstream" ]]; then
        echo "warning: 'git machete' shows that upstream of '$current' is '$machete_upstream', while upstream in the PR is '$pr_upstream'" >&2
        echo "not updating annotation for '$current'" >&2
    else
        file=$(git machete file)
        existing_anno=$(grep -Po "(?<=\\b$current\\b ).*$" $file)
        pr_num=$(grep -o 'https://bitbucket\.org/britishpearl/.*/pull-requests/[0-9]\+' <<< "$input" | grep -o '[0-9]\+$')
        new_anno="PR #$pr_num"
        if [[ "$existing_anno" != "$new_anno" ]]; then
            if [[ "$existing_anno" != "" ]]; then
                echo "warning: branch '$current' is already annotated as '$existing_anno'" >&2
                echo "not updating annotation for '$current' to '$new_anno'" >&2
            else
                sed -i "s@\\b$current\$@$current $new_anno@" $file
                echo "info: set up annotation for '$current' to '$new_anno'"
            fi
        fi
    fi
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

function dexdb() {
    dex -it $1 /usr/bin/env PGPASSWORD= psql -P pager=off -h localhost -U xxx -d $2 "${@:3}"
}

function dexdbrm() {
    dexdb $1 $2 -c 'drop schema public cascade; create schema public'
}

function dexdump() {
    dex -it $1 /usr/bin/env PGPASSWORD= pg_dump -h localhost -U xxx -d $2
}

function dexload() {
    docker exec -i $1 /usr/bin/env PGPASSWORD= psql -h localhost -U xxx -d $2
}


# Misc aliases

function .. {
    for i in `seq 1 ${1-1}`; do
        cd ..;
    done
}

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias colordiff='colordiff -u'

alias cp='cp -i'

function _kube_ps1() {
  if ! ${__display_kube_in_ps1-}; then
    echo "Using kube context $(kubectx --current)..."
  else
    __display_kube_in_ps1=true
  fi
}

function h() {
  _kube_ps1
  # For simplicity, AWS profiles are named in the same way as k8s contexts.
  aws-vault exec "$(kubectx --current)" -- helm "$@"
}

function k() {
  _kube_ps1
  aws-vault exec "$(kubectx --current)" -- kubectl "$@"
}

function kn() {
  _kube_ps1
  aws-vault exec "$(kubectx --current)" -- kubens "$@"
}

function kx() {
  __display_kube_in_ps1=true
  kubectx "$@"
}

alias ll='ls -alh'

alias mv='mv -i'

function scrabblify() {
	wget -qO- https://raw.githubusercontent.com/mkondratek/slack-scrabblifier/master/scrabblify.py | python - "$*" | xcopy && echo "Copied to clipboard"
}

alias xcopy='xclip -selection clipboard'
alias xpaste='xclip -selection clipboard -o'

alias reba='. ~/.bashrc'

alias rm='rm -iv'

alias vimba='vim ~/.bashrc; reba'


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
    # local user_and_host="\[\033[01;32m\]\u@\h"
    #local user="\[\033[01m\]\u"
    local time='$(date +%H:%M)'
    local git_branch='$(cb=$(g@); [[ $cb ]] && echo " $cb")'
    local git_machete_anno='$(cb=$(g@); [[ $cb ]] && grep -Po "(?<=${cb}) .*" $([[ -f .git/machete ]] && echo .git/machete || git machete file))'
    local git_index='$(get_git_index)'
    local prompt_tail=" \[\033[0m\033[01;35m\]\\$\[\033[0m\]"
    local kube_status='$(if [[ ${__display_kube_in_ps1-} ]]; then echo " \[\033[0m\033[1m\]$(kubectx -c):$(kubens -c)"; fi)'
    export PS1="\[\$(get_last_status_color)\]\$(get_last_status_content) \[\033[0m\033[1m\]${time} \[\033[01;34m\]\w\[\033[31m\]${git_branch}\[\033[0m\033[2m\]${git_machete_anno}\\[\$(get_git_index_color)\\]\$(get_git_index_char)${kube_status}${prompt_tail} "
}
set_up_prompt


# Command completion

## aws completion

if command -v aws &>/dev/null && [ -f ~/.local/bin/aws_bash_completer ]; then
    . ~/.local/bin/aws_bash_completer
fi

## helm completion

if command -v helm &>/dev/null; then
    eval "$(command helm completion bash)"
fi

## kops completion

if command kops version &>/dev/null; then
    eval "$(command kops completion bash)"
fi

## kubectl completion

if command -v kubectl &>/dev/null; then
    eval "$(command kubectl completion bash)"
fi

## kubectx completion
if command -v kubectx &>/dev/null && [ -f /opt/kubectx/completion/kubectx.bash ]; then
    . /opt/kubectx/completion/kubectx.bash
fi

## kubens completion
if command -v kubens &>/dev/null && [ -f /opt/kubectx/completion/kubens.bash ]; then
    . /opt/kubectx/completion/kubens.bash
fi

## minikube completion

if command -v minikube &>/dev/null; then
    eval "$(command minikube completion bash)"
fi

