_print_help() {
	if [ -e $2 ]; then
		_info "$1:"

		cat $2
		printf '\n'
	fi
}

_print_help_and_exit() {
	_print_help 'system-wide options' $_CONF_INSTALL_LIBRARY_PATH/install/help/default

	if [ "$_APPLICATION_NAME" != "install" ]; then
		_print_help $_APPLICATION_NAME $_CONF_INSTALL_LIBRARY_PATH/$_APPLICATION_NAME/help/default
		_print_help "$_APPLICATION_NAME/$_APPLICATION_CMD" $_CONF_INSTALL_LIBRARY_PATH/$_APPLICATION_NAME/help/$_APPLICATION_CMD
	fi

	exit 0
}
