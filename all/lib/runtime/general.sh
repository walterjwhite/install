_call() {
	local _function_name=$1
	shift

	type $_function_name >/dev/null 2>&1
	local _return=$?
	if [ $_return -gt 0 ]; then
		_debug "${_function_name} does not exist"

		return $_return
	fi

	$_function_name "$@"
}

_require() {
	local level=error

	if [ -z "$1" ]; then
		if [ -n "$_WARN" ]; then
			level=warn
		fi

		_$level "$2 required $_REQUIRE_DETAILED_MESSAGE" $3
		return 1
	fi

	unset _REQUIRE_DETAILED_MESSAGE
}

_read_if() {
	if [ $(env | grep -c "^$2=.*") -eq 1 ]; then
		_debug "$2 is already set"
		return 1
	fi

	[ $_NON_INTERACTIVE ] && _error "Running in non-interactive mode and user input was requested: $@" 10

	_print_log 9 STDI "$_CONF_INSTALL_C_STDIN" "$_CONF_INSTALL_BEEP_STDIN" "$1 $3"
	_interactive_alert_if $1 $3

	read -r $2
}

_interactive_alert_if() {
	_is_interactive_alert_enabled && _interactive_alert "$@"
}

_is_interactive_alert_enabled() {
	grep -cq '^_OPTN_INSTALL_INTERACTIVE_ALERT=1$' $_CONF_INSTALL_APPLICATION_CONFIG_PATH 2>/dev/null
}

_read_ifs() {
	stty -echo
	_read_if "$@"
	stty echo
}

_continue_if() {

	_read_if "$1" _PROCEED "$2"

	local proceed="$_PROCEED"
	unset _PROCEED

	if [ -z "$proceed" ]; then
		_DEFAULT=$(printf '%s' $2 | awk -F'/' {'print$1'})
		proceed=$_DEFAULT
	fi

	local proceed=$(printf '%s' "$proceed" | tr '[:lower:]' '[:upper:]')
	if [ $proceed = "N" ]; then
		return 1
	fi

	return 0
}

_() {
	local _successfulExitStatus=0
	if [ -n "$_SUCCESSFUL_EXIT_STATUS" ]; then
		_successfulExitStatus=$_SUCCESSFUL_EXIT_STATUS

		unset _SUCCESSFUL_EXIT_STATUS
	fi

	_info "## $*"
	if [ -z "$_DRY_RUN" ]; then
		"$@"

		local _exit_status=$?
		if [ $_exit_status -ne $_successfulExitStatus ]; then
			if [ -n "$_ON_FAILURE" ]; then
				$_ON_FAILURE
				return
			fi

			if [ -z "$_WARN_ON_ERROR" ]; then
				_error "Previous cmd failed" $_exit_status
			else
				unset _WARN_ON_ERROR
				_warn "Previous cmd failed - $* - $_exit_status"
				_ENVIRONMENT_FILE=$(mktemp -t error) _environment_dump

				return $_exit_status
			fi
		fi
	fi
}

_optional_include() {
	if [ ! -e $1 ]; then
		_debug "_optional_include: $1 does NOT exist"
		return 1
	fi

	. $1
}

_configure() {
	_optional_include $1
}

_error() {
	if [ $# -ge 2 ]; then
		_EXIT_STATUS=$2
	else
		_EXIT_STATUS=1
	fi

	_EXIT_LOG_LEVEL=4
	_EXIT_STATUS_CODE="ERR"
	_EXIT_COLOR_CODE="$_CONF_INSTALL_C_ERR"
	_EXIT_BEEP="$_CONF_INSTALL_BEEP_ERR"
	_EXIT_MESSAGE="$1 ($_EXIT_STATUS)"

	_defer _environment_dump

	exit $_EXIT_STATUS
}

_success() {
	_EXIT_STATUS=0

	_EXIT_LOG_LEVEL=3
	_EXIT_STATUS_CODE="SCS"
	_EXIT_COLOR_CODE="$_CONF_INSTALL_C_SCS"
	_EXIT_BEEP="$_CONF_INSTALL_BEEP_SCS"
	_EXIT_MESSAGE="$1"

	exit 0
}

_contains_argument() {
	local _key=$1
	shift

	for _ARG in "$@"; do
		case $_ARG in
		$_key)
			return 0
			;;
		esac
	done

	return 1
}

_write() {
	_sudo tee -a "$1" >/dev/null
}
