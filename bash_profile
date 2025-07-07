
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# mac os

PATH="$HOME/Library/Python/3.13/bin:$PATH"
PATH="/opt/homebrew/bin:$PATH"
PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
PATH="$(echo /usr/local/Cellar/git/*/bin):$PATH"
#PATH="$(echo /usr/local/Cellar/kubernetes-cli@*/*/bin):$PATH"
#PATH="$(echo /usr/local/Cellar/bash/*/bin):$PATH"
PATH="/usr/local/opt/gawk/libexec/gnubin:$PATH"
PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
PATH="/usr/local/opt/scala@2.13/bin:$PATH"
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

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

# akka-serialization-helper

alias ash='cd ~/akka-serialization-helper'


# git-machete

#export GIT_MACHETE_MEASURE_COMMAND_TIME=true

alias erasecov='tox -e coverage-erase'
alias gm='cd ~/git-machete'
alias isort='tox -e isort'
alias mypy='tox -e mypy'
alias pep8='tox -e pep8'
alias vulture='tox -e vulture-check'

function build-machete-snap() {
	rm -f ./*.snap
	rm-machete
	sudo snap remove git-machete
	sudo -H PATH="$PATH" sh -c "snapcraft ${1-snap} $2" && sudo snap install --classic --dangerous *.snap && git machete --version && git machete status
}

function cov() {
  if [ $# -gt 0 ]; then
    tox -e coverage -- -k "$@"
  else
    tox -e coverage-erase
    tox -e coverage
  fi
}


function m() {
	(cd ~/git-machete \
	&& pip install --break-system-packages --user . \
	&& git machete --version)
}

function p() {
  cd ~/git-machete || return 1
  if [ $# -gt 0 ]; then
    tox -e py -- -k "$@"
  else
    tox -e py
  fi
}

function pc() {
  cd ~/git-machete || return 1
  if [ $# -gt 0 ]; then
    tox -e test-completions -- -vv -k "not zsh and $*"
  else
    tox -e test-completions -- -vv -k "not zsh"
  fi
}

function rm-machete() {
	pip uninstall --yes git-machete
}


# git-machete-intellij-plugin

alias gmip='cd ~/git-machete-intellij-plugin'
alias ide='./gradlew runIde'
alias jbp='j buildPlugin'
alias jt='j :test'


# shared

. ~/.utils/bashrc-append.sh
