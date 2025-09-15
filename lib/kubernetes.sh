# Kubernetes aliases and functions

function _kube_ps1() {
  if ! ${__display_kube_in_ps1-}; then
    echo "Using kube context $(kubectx --current)..."
  else
    __display_kube_in_ps1=true
  fi
}

alias kn='_kube_ps1 && kubens'
alias ku='_kube_ps1 && kubectl'
alias kx='_kube_ps1 && kubectx'
alias tf=terraform

PATH="$PATH:$HOME/utils/kubectl-plugins"
