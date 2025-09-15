# Command completion setup

for cmd in a d dc g h k kn kx; do
  complete -F _complete_alias $cmd
done

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
