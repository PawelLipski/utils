# Prompt-related functions for bash PS1 customization

function _ps1_get_last_status_color() {
  s=$?
  [ $s -eq 0 ] && echo -ne "\033[01;32m" || echo -ne "\033[01;31m"
  exit $s # need to retain the status for _ps1_get_last_status_content
}

function _ps1_get_last_status_content() {
  s=$?
  [ $s -eq 0 ] && echo -n "➜" || echo -n "➜ ($s)"
}

function _ps1_get_git_index_color() {
  [[ -f .git/skip-git-diff-in-ps1 ]] && echo -ne "\033[0m\033[01;33m" && return 2
  git diff --quiet HEAD &>/dev/null
  [ $? -eq 1 ] && echo -ne "\033[0m\033[01;33m" && return 1
  return 0
}

function _ps1_get_git_index_char() {
  # Trick: using _ps1_get_git_index_color's exit code to save another call to git diff
  case $? in
    1) echo -n " ✗" ;;
    2) echo -n " ?" ;;
  esac
}

function _ps1_get_git_branch() {
  local cb
  cb=$(g@)
  [[ $cb ]] && echo " <git:$cb>"
}

function _ps1_get_git_machete_annotation() {
  local cb
  cb=$(g@)
  if [[ $cb && -f .git/machete ]]; then
    echo -n " "
    grep -Po "(?<=${cb} ).*" .git/machete
  fi
}

function _ps1_get_kube_status() {
  if [[ ${__display_kube_in_ps1-} ]]; then
    echo " \[\033[0m\033[1m\]$(kubectx -c):$(kubens -c)"
  fi
}

PROMPT_TIME_ZONE=Europe/Warsaw

function set_up_prompt() {
  # Build PS1 directly with proper escaping - variables that need to be expanded at setup time use ${},
  # while command substitutions that need to run each time the prompt displays use \$(...)
  export PS1="${PROMPT_HOSTNAME-}\[\$(_ps1_get_last_status_color)\]\$(_ps1_get_last_status_content) \[\033[0m\033[1m\]\$(TZ=$PROMPT_TIME_ZONE date +%H:%M) \[\033[01;36m\]\w\[\033[31m\]\$(_ps1_get_git_branch)\[\033[0m\033[2m\]\$(_ps1_get_git_machete_annotation)\[\$(_ps1_get_git_index_color)\]\$(_ps1_get_git_index_char)\$(_ps1_get_kube_status) \[\033[0m\033[01;35m\]\$\[\033[0m\] "
  export PS4='$0.$LINENO: '
}

# Initialize the prompt when this file is sourced
set_up_prompt
