function ecr_login() {
    $(aws ecr get-login --no-include-email --region us-west-2)
}


function run_linter() {
    ecr_login
    docker run -it -v $(pwd):/repo:ro 608254956046.dkr.ecr.us-west-2.amazonaws.com/arsenalbio/ci-test:v001.34 /bin/bash -c \
        'cd /repo && find "pipeline/modules" -name "*.py" -print0 | PYTHONPATH=./pipeline/modules xargs -0 python3.7 `which pylint` --disable=W --rcfile ./.pylintrc'
}

# Some config for fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
source /usr/share/doc/fzf/examples/key-bindings.bash
source /usr/share/doc/fzf/examples/completion.bash
