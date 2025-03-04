source /usr/share/doc/fzf/examples/key-bindings.bash

# export FZF_DEFAULT_COMMAND='find . -type d \( -name node_modules -o -name .git \) -prune -o -type f -print'
export FZF_DEFAULT_COMMAND='find . -type d \( -name node_modules -o -name .git \) -prune -print'
export FZF_CTRL_T_COMMAND='find . -type d \( -name node_modules -o -name .git \) -prune -o -type f -print'
