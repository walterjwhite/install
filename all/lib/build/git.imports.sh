_setup_git_import() {
	local import_git_arg="${1#*git:}"
	local import_git_url="${import_git_arg%%/*}"

	_GIT_IMPORT_PATH=$_CONF_INSTALL_APPLICATION_DATA_PATH/imports/$import_git_url
	case $import_git_arg in
	*.feature/*)
		_GIT_IMPORT_REF=$(printf "$import_git_arg" | sed -e "s/$import_git_url//")
		;;
	*)
		_GIT_IMPORT_REF=$(printf "$import_git_arg" | sed -e "s/$import_git_url/all\/lib/" -e "s/all{{_PLATFORM_}}/$_TARGET_PLATFORM/")
		;;
	esac

	if [ ! -e $_GIT_IMPORT_PATH ]; then
		git_mirrors=$_CONF_INSTALL_MIRROR_URLS project_name=$import_git_url _do_clone $_GIT_IMPORT_PATH || _error "Unable to clone git repository:$import_git_url -> $_GIT_IMPORT_PATH"

		local git_import_path_sed_safe=$(_sed_safe $_GIT_IMPORT_PATH)

	else
		local opwd=$PWD

		cd $_GIT_IMPORT_PATH
		git pull >/dev/null

		cd $opwd
	fi
}
