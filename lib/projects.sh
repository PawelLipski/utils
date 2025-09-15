# Project-specific aliases and functions

# akka-serialization-helper
alias ash='cd ~/akka-serialization-helper'

# git-machete
#export GIT_MACHETE_MEASURE_COMMAND_TIME=true
export GIT_MACHETE_DIFF_OPTS='--no-prefix'

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
