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


## JDK setup ##

setup_jdk() {
	# Remove the current JDK from PATH
	if [ -n "$JAVA_HOME" ] ; then
		PATH=${PATH/$JAVA_HOME\/bin:/}
	fi
	export JAVA_HOME=$1
	export PATH=$JAVA_HOME/bin:$PATH
}

use_java6() {
	setup_jdk /usr/lib/jvm/jdk1.6.0_45
}

use_java7() {
	setup_jdk /usr/lib/jvm/java-7-openjdk-amd64
}


# git aliases

alias @='git machete'
alias @a='git machete add'
alias @d='git machete diff'
alias @e='git machete edit'
alias @gd='git machete go down'
alias @gn='git machete go next'
alias @gp='git machete go prev'
alias @gu='git machete go up'
alias @r='git machete reapply'
alias @s='git machete status'
alias @sl='git machete status -l'
alias @t='GIT_SEQUENCE_EDITOR=: git machete traverse' # traverse without interactive rebase
alias @u='git machete update'
alias g=git
alias ga='git add'
alias gaa='git add -A .'
alias gb='git branch'
alias gbr='git branch -r'
alias gcamend='git commit -a --amend --no-edit'
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
alias gp='git push -u 2>&1 | track-prs-bb'
alias gpf='git push -u --force-with-lease 2>&1 | track-prs-bb'
alias gpl='git pull --ff-only'
alias gpld='gcod && gpl && gco -'
alias grb='git rebase'
alias grbc='git rebase --continue'
alias grbi='git rebase -i'
alias gre='git reset'
alias grehu='git reset --hard @{upstream}'
alias gs='git status'
alias gsh='git show'
alias gshp='git show @~'
alias gshx='git show --stat'
alias gsm='git submodule'
alias gsms='git submodule status'
alias gsmu='git submodule update'
alias gx='git stash'
alias gxa='git stash apply'

function @sq {
	GIT_SEQUENCE_EDITOR="sed -i '1s/^pick/reword/;2,\$s/^pick/fixup/'" git machete reapply
}

function blamestat_ {
	for dir in $@; do
		where="--work-tree=$dir --git-dir=$dir/.git"
		git $where grep -Il '' | egrep -iv '\.(pem|pub|xsd)$|license' | xargs -L1 git $where blame
	done | grep -o '^[^()]*([^():]*201' | sed 's/.*(//g; s/ *201//g' | sort | uniq -c | awk '{print $0;sum+=$1} END {print sum}'
}

function cdiff {
	colordiff -u "$@" | less -r
}

function g@ {
	git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD
}

function gar {
	name=${1-$(basename `pwd`)}
	git archive --format=zip --output=../$name.zip --prefix=$name/ -v @
}

function gcm {
	if git status | grep Untracked > /dev/null; then
		git status
	else
		git commit -am "$*"
	fi
}

function ginit {
	git init
	git add .
	git commit -m 'Initial commit'
}

function grbo {
	target_base_branch=${1}
	latest_excluded_commit=${2}
	git rebase -i --onto $target_base_branch $latest_excluded_commit `g@`
}

function gsmrehu {
	git submodule foreach "{ git symbolic-ref --quiet HEAD >/dev/null || git checkout \"\$(git for-each-ref --format='%(refname:short)' --points-at=@ --count=1 refs/heads)\"; } && git fetch && git reset --hard @{upstream}"
}


# Docker aliases

alias d='docker'
alias dcu='docker-compose up'
alias dex='docker exec'
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

copy() {
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
alias ll='ls -alF'

alias json-fmt='python -m json.tool | pygmentize -l js'

alias mntdb='sudo mount -t vmhgfs .host:/Dropbox ~/Dropbox'

alias mv='mv -i'

#paste() {
#	cp -ir /tmp/__buffer/* .
#}

alias reba='. ~/.bashrc'

alias rm='rm -iv'

alias sagi='sudo apt-get install'

alias vimba='vim ~/.bashrc; reba'

# http://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

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
	[ $? -eq 1 ] && echo -ne "\033[01;33m" && exit 1
	exit 0
}

get_git_index_char() {
	# Trick: using get_git_index_color's exit code to save another call to git diff-index
	[ $? -eq 1 ] && echo -n ✗
}

set_up_prompt() {
    # local user_and_host="\[\033[01;32m\]\u@\h"
    local user_and_host="\[\033[01;32m\]\u"
    local cur_location="\[\033[01;34m\]\w"
    local git_branch_color="\[\033[31m\]"
    local git_branch='`git status 2>/dev/null >/dev/null && echo -n " " && g@`'
    local git_index='`get_git_index`'
    local prompt_tail=" \[\033[35m\]$\[\033[00m\]"
    export PS1="\[\`get_last_status_color\`\]\`get_last_status_content\` \[\033[0m\033[1m\]#\$\$ ${cur_location}${git_branch_color}${git_branch}\\[\`get_git_index_color\`\\]\`get_git_index_char\`${prompt_tail} "
}
set_up_prompt

# sbt opts and aliases

export SBT_OPTS="-Xmx2G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xss2M"

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
	eval "$(helm completion bash)"
fi

## kops completion

if command -v kops &>/dev/null; then
	eval "$(kops completion bash)"
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

## minikube completion

if command -v minikube &>/dev/null; then
	eval "$(minikube completion bash)"
fi

