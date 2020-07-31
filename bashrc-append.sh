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


# Shell options

shopt -s dotglob

# Vars

export EDITOR=vim
export HISTSIZE=-1 #


# Marks/jumping

export MARKPATH=$HOME/.marks

function jump {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

function mark {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}

function unmark {
    rm -i "$MARKPATH/$1"
}

function marks {
    ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}

_completemarks() {
    local curw=${COMP_WORDS[COMP_CWORD]}
    local wordlist=$(find $MARKPATH -type l -printf "%f\n")
    COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
    return 0
}

complete -F _completemarks jump unmark
alias jmp=jump


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
alias gcamendpf='gcamend && gpf'
alias gcamende='git commit -a --amend'
alias gco='git checkout --recurse-submodules'
alias gco@='gco "$(git log --no-walk --format=%D --decorate --decorate-refs=refs/heads)"'
alias gcod='gco develop'
alias gcom='gco master'
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
alias gdw='git diff --word-diff'
alias gdx='git diff --stat'
alias gf='git fetch'
alias ggr='git grep'
alias gl='git log'
alias gld='git log develop'
alias gll="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
alias glm='git log master'
alias glod='git log origin/develop'
alias glom='git log origin/master'
alias glpf='git log --pretty=fuller'
alias gm='git merge --ff-only'
alias gp='git push -u 2>&1 | track-prs-bb'
alias gpf='git push -u --force-with-lease 2>&1 | track-prs-bb'
alias gpl='git pull --ff-only'
alias gpld='gcod && gpl && gco -'
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
alias hcism='hub ci-status master'

function @sq {
    GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/reword/;2,\$s/^pick/fixup/'" git machete reapply
}

function blamestat {
    for dir in ${1-.}; do
        where="--work-tree=$dir --git-dir=$dir/.git"
        git $where grep --no-recurse-submodules -Il '' | egrep -iv '\.(pem|pub|xsd)$|license' | xargs -L1 git $where blame --line-porcelain | grep -Po '(?<=^author-mail <).*(?=@)'
    done | sort | uniq -c | awk '{ print; sum += $1 } END { print sum }'
}

function cdiff {
    colordiff -u "$@" | less -r
}

function g@ {
    git symbolic-ref --short --quiet HEAD 2>/dev/null || git machete show current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
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


# Docker aliases

alias d='docker'
alias dcu='docker-compose up'
alias dex='docker exec'
alias dim='docker images'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias drm='docker rm'
alias drmi='docker rmi'
alias gc-docker='docker rm $(docker ps --filter status=exited --filter status=created -q) && docker image prune'

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

function anno-prs() {
    hub pr list --format "%I %au %H%n" | while read -r id author head; do
        local me=$(grep -Po '(?<=user: ).*' ~/.config/hub)
        local a=$([[ $author != "$me" ]] && echo " ($author)")
        git machete anno --branch="${head#*:}" "PR #${id}${a}"
    done
    git machete status
}

function create-pr() {
    [[ $# == 0 ]] || { echo "No params allowed."; exit 1; }
    local me=$(grep -Po '(?<=user: ).*' ~/.config/hub)
    hub pull-request \
        --no-edit \
        --push \
        --base="$(git machete show up | sed 's!^origin/!!')" \
        --assign="$me" \
        --milestone="$(cat .git/info/milestone 2>/dev/null | tr -d ' ' || true)" \
        --reviewer="$(cat .git/info/reviewers 2>/dev/null | paste -sd, | sed 's/^,//; s/,\+/,/g; s/,$//' || true)" \
        --browse || return 1
    read -r pr_number < <(hub pr show --format=%I)
    git machete anno "PR #$pr_number"
}

function ls-prs() {
    hub pr list --format "%pC%<(8)%i%Creset     %<(50)%H -> %B%n"
}

function retarget-pr() {
    org_and_repo=$(git remote get-url origin | grep 'github\.com' | grep -Eo '[^/:]+/[^/:]+\.git$' | sed 's/\.git$//')
    # Token is used implicitly by 'hub', and explicitly for the API call.
    # 'xargs' with no arguments trims leading and trailing whitespace from the input string.
    hub_token=$(grep 'oauth_token:' ~/.config/hub | cut -d: -f2 | xargs)

    curl -XPATCH \
        -H "Authorization: token $hub_token" \
        -H "Content-Type: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$org_and_repo/pulls/$(hub pr show --format=%I)" \
        -d "{ \"base\": \"$(git machete show up)\" }" \
        --fail \
        --silent \
        --show-error \
        -o/dev/null \
        -w "> %{http_code}\n" \
    && ls-prs
}

function view-pr() {
    [[ $1 ]] || { echo "Usage: view-pr <github-pr-number>"; return 1; }
    pr_number=$1
    git diff-index --quiet HEAD || { echo "You have uncommitted changes, aborting"; return 1; }
    output=$(hub pr show --format='%B %H %au %S' "$pr_number" 2>/dev/null)
    [[ $? -eq 0 ]] || { echo "PR #$pr_number not found"; return 1; }
    read -r base head author state <<< "$output"
    [[ $state == open ]] || { echo "PR #$pr_number is closed"; return 1; }
    git fetch || return 1
    git checkout "$head" || return 1
    if ! git machete is-managed; then
        if git machete is-managed "$base"; then
            git machete add --onto="$base" || return 1
        elif git machete is-managed "origin/$base"; then
            git machete add --onto="origin/$base" || return 1
        else
            git machete status -l
            return 0
        fi
    fi
    git machete anno "PR #$pr_number ($author)" || return 1
    git machete status -l
}

function copy() {
    buf=/tmp/__buffer
    rm -rf $buf
    mkdir $buf
    cp -r $1 $buf
}

alias colordiff='colordiff -u'

alias cp='cp -i'

alias disk-control='sudo smartctl -a /dev/sda'

alias gnuplot-colors='gnuplot -e "show palette colornames" 2>&1 | sort'

alias gri='grep -Ri'

alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alh'

alias mv='mv -i'

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

alias reba='. ~/.bashrc'

alias rm='rm -iv'

alias sagi='sudo apt-get install'

alias vimba='vim ~/.bashrc; reba'

# http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
HISTCONTROL=ignoredups:erasedups  # no duplicate entries
HISTSIZE=100000                   # big big history
HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r"

export CDPATH='.:~'

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
    export PS1="\[\$(get_last_status_color)\]\$(get_last_status_content) \[\033[0m\033[1m\]${time} \[\033[01;34m\]\w\[\033[31m\]${git_branch}\[\033[0m\033[2m\]${git_machete_anno}\\[\$(get_git_index_color)\\]\$(get_git_index_char)${prompt_tail} "
}
set_up_prompt

track-prs-bb() {
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

# k8s/Helm helpers

helmdiff() {
    [[ $# -eq 3 ]] || { echo "usage: helmdiff <release> <chart> <values-file>" 2>&1; return 1; }
    release=$1
    chart=$2
    values_file=$3
    colordiff -u <(helm get $release) <(helm upgrade --debug --dry-run $release $chart -f $values_file)
}

kbash() {
    kexec "$1" bash
}

kcat() {
    kexec "$1" cat $2
}

kcp() {
    from_pod=$(kgetpod $1)
    to_pod=$(kgetpod $2)
    path=$3
    tmp=$(mktemp -d)/$(basename $path)
    kubectl cp $from_pod:$path $tmp
    kubectl exec -t "$to_pod" -- rm -r $path
    kubectl cp $tmp $to_pod:$path
    rm -rf $tmp
}

kdiff() {
    pod1=$(kgetpod $1)
    pod2=$(kgetpod $2)
    path=$3
    tmp1=$(mktemp -d)/$pod1-$(basename $path)
    tmp2=$(mktemp -d)/$pod2-$(basename $path)
    kubectl cp $pod1:$path $tmp1
    kubectl cp $pod2:$path $tmp2
    colordiff -u $tmp1 $tmp2
    rm -f $tmp1 $tmp2
}

kexec() {
    kubectl exec -it "$(kgetpod $1)" -- "${@:2}"
}

kgetpod() {
    kubectl get pods -l app="$1" -o jsonpath='{.items[0].metadata.name}'
}

kls() {
    kexec "$1" ls $2
}

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

