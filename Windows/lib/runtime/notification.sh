_notify() {
	if [ $# -ne 3 ]; then
		printf '3 args are required (title, body)\n'
		exit 1
	fi

	powershell -f $_CONF_INSTALL_APPLICATION_LIBRARY_PATH/notifications.ps1 "$_APPLICATION_NAME - $_APPLICATION_CMD" $@
}
