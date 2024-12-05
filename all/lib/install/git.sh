_do_clone() {
	if [ -n "$1" ] && [ -e $1 ]; then
		if [ -z "$clean_workspace" ] || [ $clean_workspace -eq 0 ]; then
			local opwd=$PWD
			cd $1
			git pull

			cd $opwd

			return
		fi

		cd
		rm -rf $1
	fi

	if [ -n "$project_name" ]; then
		git clone $project_name $1 >/dev/null 2>&1 && return
	fi

	local repository_url
	for repository_url in $git_mirrors; do
		local project_url=$repository_url
		if [ -n "$project_name" ]; then
			project_url=$project_url/$project_name
		fi

		_git_does_repository_exist $project_url || continue

		_detail "Using $project_url -> $1"
		git clone $project_url $1 >/dev/null 2>&1 && return
	done

	return 1
}

_clone() {
	_info "Git Clone: $_TARGET_APPLICATION_NAME"

	git_mirrors=$_CONF_INSTALL_APP_REGISTRY_GIT_URL clean_workspace=$_CONF_INSTALL_CLEAN_APP_REGISTRY_WORKSPACE _do_clone $_CONF_INSTALL_DATA_REGISTRY_PATH && {
		cd $_CONF_INSTALL_DATA_REGISTRY_PATH

		cd $_TARGET_APPLICATION_NAME || _error "$_TARGET_APPLICATION_NAME does not exist in the registry"
		_detail "Cloned registry and $_TARGET_APPLICATION_NAME exists"
		return
	}

	_error "Unable to clone: $_TARGET_APPLICATION_GIT_URL in any of $_CONF_INSTALL_APP_REGISTRY_GIT_URL"
}

_git_does_repository_exist() {
	case $1 in
	http*)
		local http_status_code=$(curl -Is $1 2>/dev/null | head -n 1 | cut -d$' ' -f2)
		if [ $http_status_code -lt 400 ]; then
			return 0
		fi
		;;
	*:*)
		git ls-remote $1 >/dev/null 2>&1 && return 0
		;;
	*)
		if [ -e $1 ]; then
			return 0
		fi
		;;
	esac

	return 1
}

_require_ssh_keys() {
	if [ $(find ~/.ssh -maxdepth 1 -type f -name '*.pub' | wc -l) -eq 0 ]; then
		_error "SSH public key is required"
	fi
}
