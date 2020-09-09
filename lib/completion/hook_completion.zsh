# Source this script from ~/.zshrc
_hook_targets()
{
    local cmds cur ff
    if (($COMP_CWORD == 1))
    then
        cur="${COMP_WORDS[1]}"
        cmds="$(hook help -c)"
        COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
        COMPREPLY=( "${COMPREPLY[@]/%/ }" )
    else
        # get all matching files and directories
        COMPREPLY=($(compgen -f  -- "${COMP_WORDS[$COMP_CWORD]}"))

        for ((ff=0; ff<${#COMPREPLY[@]}; ff++)); do
            [[ -d ${COMPREPLY[$ff]} ]] && COMPREPLY[$ff]+='/'
            [[ -f ${COMPREPLY[$ff]} ]] && COMPREPLY[$ff]+=' '
        done
    fi
}

complete -o bashdefault -o default -o nospace -F _hook_targets hook
