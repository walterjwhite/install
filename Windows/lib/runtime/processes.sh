_is_backgrounded() {
	return 1
}

_list_pid_info() {
	_TARGET_PID=$(basename $_EXISTING_APPLICATION_PIPE)

	_TARGET_PS_DTL=$(ps -p $_TARGET_PID | sed 1d | awk {'print$8'} | sed -e "s/^.*$_EXECUTABLE_NAME_SED_SAFE/$_EXECUTABLE_NAME_SED_SAFE/")

	_info " $_TARGET_PID - $_TARGET_PS_DTL"
}
