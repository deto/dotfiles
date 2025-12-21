# Some config for fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# source /usr/share/doc/fzf/examples/key-bindings.bash
# source /usr/share/doc/fzf/examples/completion.bash

function gssh() {
    # 1. Capture the target instance (first argument)
    local target="$1"

    # 2. Shift the arguments so "$@" now contains only the remaining flags (like --zone)
    shift

    # 3. Check if user already typed 'user@instance'. If not, prepend 'ubuntu@'
    if [[ "$target" != *"@"* ]]; then
        target="ubuntu@$target"
    fi

    # 4. Run the command
    gcloud compute ssh "$target" "$@" -- \
        -L 8787:localhost:8787 \
        -A \
        -Y \
        -o SendEnv="AWS_*"
}
