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

# Function to find and activate a .venv
_auto_activate_venv() {
    local VENV_PATH=""
    local CURRENT_DIR="$PWD"

    # Loop up the directory tree looking for a .venv folder
    while [[ "$CURRENT_DIR" != "/" ]]; do
        if [[ -d "$CURRENT_DIR/.venv" ]]; then
            VENV_PATH="$CURRENT_DIR/.venv"
            break
        fi
        # Move up one directory
        CURRENT_DIR="$(dirname "$CURRENT_DIR")"
    done

    # If a .venv was found
    if [[ -n "$VENV_PATH" ]]; then
        # Check if the found venv is already active
        if [[ "$VIRTUAL_ENV" == "$VENV_PATH" ]]; then
            # Found venv is already active, do nothing
            return 0
        fi

        # Found venv is NOT the active one (or none is active)
        # Deactivate if a different venv is currently active
        if [[ -n "$VIRTUAL_ENV" ]]; then
            echo "Deactivating $VIRTUAL_ENV"
            deactivate 2>/dev/null
        fi

        # Activate the new venv
        if [[ -f "$VENV_PATH/bin/activate" ]]; then
            echo "Activating virtual environment at $VENV_PATH"
            # Use 'source' to run the activation script in the current shell
            source "$VENV_PATH/bin/activate"
        else
            echo "Error: Found .venv at $VENV_PATH but 'activate' script is missing." >&2
        fi

    # If no .venv was found, and one is currently active, deactivate it
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        echo "Deactivating $VIRTUAL_ENV (leaving venv context)"
        deactivate 2>/dev/null
    fi
}

# This function overrides the 'cd' built-in to add our auto-activate logic
# We could use chpwd if we were in zsh, but not supported in all bash shells
cd() {
    # 1. Execute the built-in 'cd' command with all arguments passed to this function
    builtin cd "$@"

    # 2. Check the exit status of the built-in 'cd'.
    #    If the directory change was successful (exit status 0),
    #    then run our virtual environment logic.
    if [[ $? -eq 0 ]]; then
        _auto_activate_venv
    fi
    return $?
}
