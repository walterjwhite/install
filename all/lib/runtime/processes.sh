import time.sh

_on_exit() {
	[ $_EXIT ] && return 1

	_EXIT=0
	if [ -n "$_DEFERS" ]; then
		for _DEFER in $_DEFERS; do
			_call $_DEFER
		done

		unset _DEFERS
	fi

	_waitee_done

	if [ $_EXIT_STATUS -gt 0 ]; then
		_log_level=warn
	else
		_log_level=debug
	fi

	[ "$_EXIT_MESSAGE" ] && _print_log $_EXIT_LOG_LEVEL "$_EXIT_STATUS_CODE" "$_EXIT_COLOR_CODE" "$_EXIT_BEEP" "$_EXIT_MESSAGE"

	_log_app "exit"

	_on_exit_beep
}

_defer() {
	_debug "deferring: $1"
	_DEFERS="${_DEFERS:+$_DEFERS }$1"
}

_on_exit_beep() {
	local current_time=$(date +%s)
	local timeout=$(($current_time + $_CONF_INSTALL_BEEP_TIMEOUT))
	[ $current_time -le $timeout ] && return 1

	local beep_code
	if [ $_EXIT_STATUS -gt 0 ]; then
		beep_code="$_CONF_INSTALL_BEEP_ERR"
	else
		beep_code="$_CONF_INSTALL_BEEP_SCS"
	fi

	_beep "$beep_code" &
}

_context_id_is_valid() {
	printf '%s' "$1" | $_CONF_INSTALL_GNU_GREP -Pq '^[a-zA-Z0-9_+-]+$' || _error "Context ID *MUST* only contain alphanumeric characters and +-: '^[a-zA-Z0-9_+-]+$' | ($1)"
}

_init_application_context() {
	if [ -z "$_CONTEXT_VALIDATED" ]; then
		_context_id_is_valid "$_CONF_INSTALL_CONTEXT"
		_CONTEXT_VALIDATED=0

	fi

	_APPLICATION_CONTEXT_GROUP=$_CONF_INSTALL_RUN_PATH/$_CONF_INSTALL_CONTEXT
	_APPLICATION_CMD_DIR=$_APPLICATION_CONTEXT_GROUP/$_APPLICATION_NAME/$_APPLICATION_CMD
	_APPLICATION_PIPE=$_APPLICATION_CMD_DIR/$$
	_APPLICATION_PIPE_DIR=$(dirname $_APPLICATION_PIPE)

	mkdir -p $_APPLICATION_PIPE_DIR
	mkfifo $_APPLICATION_PIPE

	_init_configuration

	$_CONF_INSTALL_WAITER_LEVEL "($_APPLICATION_CMD) Please use -w=$$"
}

_init_configuration() {
	if [ -z "$_CONFIGURATIONS" ]; then
		if [ "$_APPLICATION_NAME" != "install" ]; then
			_configure $_CONF_INSTALL_CONFIG_PATH/install
		fi

		_configure $_CONF_INSTALL_APPLICATION_CONFIG_PATH
		return 1
	fi

	local configure
	for configure in $(printf '%s\n' $_CONFIGURATIONS); do
		_configure $_CONF_INSTALL_CONFIG_PATH/$configure
	done
}

_has_other_instances() {
	if [ $(find $_APPLICATION_CMD_DIR -maxdepth 1 -type p ! -name $$ | wc -l) -gt 0 ]; then
		return 0
	fi

	return 1
}

_waitee_done() {
	if [ -z "$_EXIT_STATUS" ]; then
		_EXIT_STATUS=0
	fi

	if [ -n "$_WAITEE" ] && [ -e $_APPLICATION_PIPE ]; then
		_info "$0 process completed, notifying ($_EXIT_STATUS)"

		printf '%s\n' "$_EXIT_STATUS" >$_APPLICATION_PIPE

		_info "$0 downstream process picked up"
	fi

	rm -f $_APPLICATION_PIPE
}

_waiter() {
	if [ -n "$_WAITER_PID" ]; then
		_UPSTREAM_APPLICATION_PIPE=$(find $_APPLICATION_CONTEXT_GROUP -type p -name $_WAITER_PID 2>/dev/null | head -1)

		if [ -z "$_UPSTREAM_APPLICATION_PIPE" ]; then
			_error "$_WAITER_PID not found"
		fi

		if [ ! -e $_UPSTREAM_APPLICATION_PIPE ]; then
			_warn "$_UPSTREAM_APPLICATION_PIPE does not exist, did upstream start?"
			return
		fi

		_info "Waiting for upstream to complete: $_WAITER_PID"

		while [ 1 ]; do
			if [ ! -e $_UPSTREAM_APPLICATION_PIPE ]; then
				_error "Upstream pipe no longer exists"
			fi

			_UPSTREAM_APPLICATION_STATUS=$(_timeout $_CONF_INSTALL_WAIT_INTERVAL "_waiter:upstream" cat $_UPSTREAM_APPLICATION_PIPE 2>/dev/null)

			local _UPSTREAM_STATUS=$?
			if [ $_UPSTREAM_STATUS -eq 0 ]; then
				if [ -z "$_UPSTREAM_APPLICATION_STATUS" ] || [ $_UPSTREAM_APPLICATION_STATUS -gt 0 ]; then
					_error "Upstream exited with error ($_UPSTREAM_APPLICATION_STATUS)"
				fi

				_warn "Upstream finished: $_UPSTREAM_APPLICATION_PIPE ($_UPSTREAM_STATUS)"
				break
			fi

			_detail " Upstream is still running: $_UPSTREAM_APPLICATION_PIPE ($_UPSTREAM_STATUS)"
		done
	fi
}

_kill_all() {
	_do_kill_all $_APPLICATION_PIPE_DIR
}

_kill_all_group() {
	_do_kill_all $_APPLICATION_CONTEXT_GROUP
}

_do_kill_all() {
	for _EXISTING_APPLICATION_PIPE in $(find $1 -type p -not -name $$); do
		_kill $(basename $_EXISTING_APPLICATION_PIPE)
	done
}

_kill() {
	_warn "Killing $1"
	kill -TERM $1
}

_list() {
	_list_pid_infos $_APPLICATION_PIPE_DIR
}

_list_group() {
	_list_pid_infos $_APPLICATION_CONTEXT_GROUP
}

_list_pid_infos() {
	_info "Running processes:"

	_EXECUTABLE_NAME_SED_SAFE=$(_sed_safe $0)

	for _EXISTING_APPLICATION_PIPE in $(find $1 -type p -not -name $$); do
		_list_pid_info
	done
}

_parent_processes() {
	[ -n "$_PARENT_PROCESSES_FUNCTION" ] && $_PARENT_PROCESSES_FUNCTION
}

_parent_processes_pgrep() {
	pgrep -P $1
}

_init_pager() {
	[ "$_CONF_INSTALL_NO_PAGER" = "1" ] && PAGER=cat
}
