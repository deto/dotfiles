function ecr_login() {
    $(aws ecr get-login --no-include-email --region us-west-2)
}
