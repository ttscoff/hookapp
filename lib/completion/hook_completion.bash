complete -F get_hook_targets hook

function get_hook_targets()
{
    COMPREPLY=(`hook help -c "${COMP_WORDS[@]:1}"`)
}
