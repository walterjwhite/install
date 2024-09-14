_prepare_target() {
	_sudo rm -rf $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME
	_sudo mkdir -p $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME
}

_install() {
	_sudo mkdir -p $_INSTALL_BIN_PATH

	_install_help $1

	local installed_files=$(mktemp)
	_install_cmds $1 $installed_files
	_install_uninstall $1

	_install_files_files $1 $installed_files
	_install_update_files $installed_files

	if [ -e $1/.metadata ]; then
		cat $1/.metadata | _write "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.metadata"
	fi
}

_install_files() {
	if [ -e $1 ] && [ $(find $1 -type f | wc -l) -gt 0 ]; then
		if [ -n "$3" ]; then
			local files_sed_safe=$(_sed_safe $1)
			local target_sed_safe=$(_sed_safe $2)

			find $1 -type f | sed -e "s/^$files_sed_safe/$target_sed_safe/" >>$3
		fi

		_sudo mkdir -p $2
		tar -c $_TAR_ARGS -C $1 . | _sudo tar -xop $_TAR_ARGS -C $2
	fi
}

_install_help() {
	_install_files $1/help $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/help
}

_install_cmds() {
	if [ "$_TARGET_APPLICATION_NAME" = "$_APPLICATION_NAME" ]; then
		printf '%s\n' "$_INSTALL_BIN_PATH/$(basename $0)" >>$2
	fi

	_install_files $1/bin $_INSTALL_BIN_PATH $2
}

_install_uninstall() {
	_install_files $1/uninstall $_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/uninstall
}

_install_files_files() {
	_install_files $1/files/_ROOT_ $_ROOT $2
	_install_files $1/files/_APPLICATION_ROOT_ "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME" $2
}

_install_update_files() {
	if [ -n "$_ROOT" ] && [ "$_ROOT" != "/" ]; then
		local root_sed_safe=$(_sed_safe $_ROOT)
		$_CONF_INSTALL_GNU_SED -i "s/^$root_sed_safe//" $1
	fi

	_INSTALLED_FILES="$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files"
	cat $1 | _write "$_INSTALLED_FILES"
	rm -f $1

	_sudo chmod 444 $_INSTALLED_FILES
}
