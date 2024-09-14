_is_backgrounded() {
	case $(ps -o stat= -p $$) in
	*+*)
		return 1
		;;
	esac

	return 0
}

_list_pid_info() {
	_TARGET_PID=$(basename $_EXISTING_APPLICATION_PIPE)

	_TARGET_PS_DTL=$(ps -o command -p $_TARGET_PID | sed 1d | sed -e "s/^.*$_EXECUTABLE_NAME_SED_SAFE/$_EXECUTABLE_NAME_SED_SAFE/")

	_info " $_TARGET_PID - $_TARGET_PS_DTL"
}
