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

DEVELOP=develop

alias @='git machete'
alias @a='git machete add'
alias @d='git machete diff'
alias @e='git machete edit'
alias @gd='git machete go down'
alias @gu='git machete go up'
alias @r='git machete reapply'
alias @s='git machete status'
alias @sl='git machete status -l'
alias @sq="GIT_SEQUENCE_EDITOR='sed -i \"1s/^pick/reword/;2,\\\$s/^pick/fixup/\"' git machete reapply" # squash
alias @t='GIT_SEQUENCE_EDITOR=: git machete traverse' # traverse without interactive editor
alias @u='git machete update'
alias g=git
alias ga='git add'
alias gaa='git add -A .'
alias gb='git branch'
alias gbr='git branch -r'
alias gcamend='git commit -a --amend --no-edit'
alias gcamende='git commit -a --amend'
alias gco='git checkout'
alias gco@='git checkout "$(git log --no-walk --format=%D --decorate --decorate-refs=refs/heads)"'
alias gcod="git checkout $DEVELOP"
alias gcom="git checkout master"
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gd='git diff -M'
alias gdd="git diff -M $DEVELOP"
alias gddx="git diff --stat $DEVELOP"
alias gdh='git diff -M @'
alias gdhx='git diff --stat @'
alias gdno='git diff --name-only'
alias gdp='git diff -M @~'
alias gdpx='git diff --stat @~'
alias gdw='git diff --word-diff'
alias gdx='git diff --stat'
alias gf='git fetch'
alias ggr='git grep'
alias gl='git log'
alias gll="git log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)'"
alias glo='git log origin/`g@`'
alias gld="git log $DEVELOP"
alias glod="git log origin/$DEVELOP"
alias gp='git push -u 2>&1 | track-prs-bb'
alias gpf='git push -u -f 2>&1 | track-prs-bb'
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
alias gsmrehu='git submodule foreach "git fetch && git reset --hard @{upstream}"'
alias gsmu='git submodule update'
alias gx='git stash'
alias gxa='git stash apply'

g@ () {
	git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD
}

gar() {
	name=${1-$(basename `pwd`)}
	git archive --format=zip --output=../$name.zip --prefix=$name/ -v @
}

gcm() {
	if git status | grep Untracked > /dev/null; then
		git status
	else
		git commit -am "$*"
	fi
}

ginit() {
	git init
	git add .
	git commit -m 'Initial commit'
}

grbo() {
	target_base_branch=${1}
	latest_excluded_commit=${2}
	git rebase -i --onto $target_base_branch $latest_excluded_commit `g@`
}

blamestat_() {
	for dir in $@; do
		where="--work-tree=$dir --git-dir=$dir/.git"
		git $where grep -Il '' | egrep -v '\.(pem|pub|xsd)$' | xargs -L1 git $where blame
	done | grep -o '^[^()]*([^():]*201' | sed 's/.*(//g; s/ *201//g' | sort | uniq -c | awk '{print $0;sum+=$1} END {print sum}'
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

alias rm='rm -i'

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

set_up_prompt() {
    #local user_and_host="\[\033[01;32m\]\u@\h"
    local user_and_host="\[\033[01;32m\]\u"
    local cur_location="\[\033[01;34m\]\w"
    local git_branch_color="\[\033[31m\]"
    local git_branch='`git status 2>/dev/null >/dev/null && g@`'
    local prompt_tail="\[\033[35m\]$"
    local last_color="\[\033[00m\]"
    export PS1="$user_and_host ${cur_location} ${git_branch_color}${git_branch}${prompt_tail}${last_color} "
}
set_up_prompt

# sbt opts and aliases

export SBT_OPTS="-Xmx2G -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Xss2M"

