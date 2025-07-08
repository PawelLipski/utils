
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

. ~/.utils/bashrc-append.sh

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/pawel.lipski/.sdkman"
[[ -s "/Users/pawel.lipski/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/pawel.lipski/.sdkman/bin/sdkman-init.sh"
