# Git aliases and functions

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
alias gco='git checkout'
alias gcod='gco develop'
alias gcom='gco master'
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gdd="gd develop"
alias gddx="gd --stat develop"
alias gdhx='gd --stat @'
alias gdm='gd master'
alias gdno='gd --name-only'
alias gdp='gd @~'
alias gdpx='gd --stat @~'
alias gdu='gd @{upstream}'
alias gdw='gd --word-diff'
alias gdx='gd --stat'
alias gf='git fetch --prune'
alias ggr='git grep -n'
alias ggri='git grep -ni'
alias gl='git log'
alias gld='git log develop'
alias glf='git ls-files'
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
alias gsh='git show --pretty=fuller --no-prefix'
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
    git diff --no-prefix -M @
  else
    git diff --no-prefix -M "$@"
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

function git-set-ssh-key() {
  key_path=$1  # e.g. /Users/pawel.lipski/.ssh/id_rsa
  git config core.sshCommand "/usr/bin/ssh -i $key_path"  # sets on a per-repo basis
}

function remove_matching_lines_from_files() {
  regex=$1
  git grep -E -l "$regex" -- "${@:2}" | xargs sed -E -i "/${regex//\//\\/}/ d"
}

# e.g. replace_in_files 'import org.scalatestplus.junit.FilterableJUnitRunner' 'import org.scalatest.junit.FilterableJUnitRunner' '*.scala'
function replace_in_files() {
  from=$1
  to=$2
  git grep -E -l "$from" -- "${@:3}" | xargs sed -E -i "s!$from!$to!g"
}

# e.g. files_with_but_not scala_library scala_version '*.bazel'
function files_with_but_not() {
  with=$1
  but_not=$2
  git grep -l "$with" -- "${@:3}" | xargs git grep --files-without-match "$but_not"
}

function files_with_both() {
  with1=$1
  with2=$2
  git grep -l --all-match -e "$with1" --or -e "$with2" -- "${@:3}"
}
