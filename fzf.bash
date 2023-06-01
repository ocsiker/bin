export FZF_DEFAULT_COMMAND='find . -type d -name node_modules -prune -o -type d -name "?git" -prune -o -name "*"'
export FZF_DEFAULT_OPTS="--height 40% --reverse --border --preview='less {}'\
        --bind ctrl-u:preview-page-up,ctrl-d:preview-page-down"
# for ctrl T 

export FZF_CTRL_T_COMMAND='find . -type d -name node_modules -prune -o -type d -name "?git" -prune -o -name "*"'
export FZF_CTRL_T_OPTS="--height 40% --reverse --border --preview='less {}'\
        --bind ctrl-u:preview-page-up,ctrl-d:preview-page-down"


