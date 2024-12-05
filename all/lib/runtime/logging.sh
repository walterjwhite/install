_init_logging() {
	unset _LOGFILE

	case $_CONF_INSTALL_LOG_LEVEL in
	0)
		local logfile=$(_mktemp debug)

		_warn "Writing debug contents to: $logfile"
		_set_logfile "$logfile"
		set -x
		;;
	esac
}

_set_logfile() {
	if [ -n "$1" ]; then
		_LOGFILE=$1

		mkdir -p $(dirname $1)

		exec >>$1
		exec 2>>$1
	fi
}

_reset_logging() {
	exec >&7
	exec 2>&8
}

_alert() {
	_print_log 5 ALRT "$_CONF_INSTALL_C_ALRT" "$_CONF_INSTALL_BEEP_ALRT" "$1"

	local recipients="$_OPTN_INSTALL_ALERT_RECIPIENTS"
	local subject="Alert: $0 - $1"

	if [ -z "$recipients" ]; then
		_warn "recipients is empty, aborting"
		return 1
	fi

	_mail "$recipients" "$subject" "$2"
}

_warn() {
	_print_log 3 WRN "$_CONF_INSTALL_C_WRN" "$_CONF_INSTALL_BEEP_WRN" "$1"
}

_info() {
	_print_log 2 INF "$_CONF_INSTALL_C_INFO" "$_CONF_INSTALL_BEEP_INFO" "$1"
}

_detail() {
	_print_log 2 DTL "$_CONF_INSTALL_C_DETAIL" "$_CONF_INSTALL_BEEP_DETAIL" "$1"
}

_debug() {
	_print_log 1 DBG "$_CONF_INSTALL_C_DEBUG" "$_CONF_INSTALL_BEEP_DEBUG" "($$) $1"
}


_do_log() {
	:
}

_colorize_text() {
	printf '\033[%s%s\033[0m' "$1" "$2"
}

_sed_remove_nonprintable_characters() {
	sed -e 's/[^[:print:]]//g'
}

_print_log() {
	if [ -z "$5" ]; then
		if test ! -t 0; then
			cat - | _sed_remove_nonprintable_characters |
				while read _line; do
					_print_log $1 $2 $3 $4 "$_line"
				done

			return
		fi

		return
	fi

	local _level=$1
	local _slevel=$2
	local _color=$3
	local _tone=$4
	local _message="$5"

	if [ $_level -lt $_CONF_INSTALL_LOG_LEVEL ]; then
		return
	fi

	[ -n "$_LOGGING_CONTEXT" ] && _message="$_LOGGING_CONTEXT - $_message"

	local _message_date_time=$(date +"$_CONF_INSTALL_DATE_FORMAT")
	if [ $_BACKGROUNDED ] && [ $_OPTN_INSTALL_BACKGROUND_NOTIFICATION_METHOD ]; then
		$_OPTN_INSTALL_BACKGROUND_NOTIFICATION_METHOD "$_slevel" "$_message" &
	fi

	_do_log "$_level" "$_slevel" "$_message"
	[ -n "$_tone" ] && _beep "$_tone"

	_log_to_file "$_slevel" "$_message_date_time" "${_LOG_INDENT}$_message"
	_log_to_console "$_color" "$_slevel" "$_message_date_time" "${_LOG_INDENT}$_message"
}

_add_logging_context() {
	if [ -z "$1" ]; then
		return 1
	fi

	if [ -z "$_LOGGING_CONTEXT" ]; then
		_LOGGING_CONTEXT="$1"
		return
	fi

	_LOGGING_CONTEXT="$_LOGGING_CONTEXT.$1"
}

_remove_logging_context() {
	if [ -z "$_LOGGING_CONTEXT" ]; then
		return 1
	fi

	case $_LOGGING_CONTEXT in
	*.*)
		_LOGGING_CONTEXT=$(printf '%s' "$_LOGGING_CONTEXT" | sed 's/\.[a-z0-9 _-]*$//')
		;;
	*)
		unset _LOGGING_CONTEXT
		;;
	esac
}

_increase_indent() {
	_LOG_INDENT="$_LOG_INDENT${_CONF_INSTALL_INDENT}"
}

_decrease_indent() {
	_LOG_INDENT=$(printf '%s' "$_LOG_INDENT" | sed -e "s/${_CONF_INSTALL_INDENT}$//")
	[ ${#_LOG_INDENT} -eq 0 ] && _reset_indent
}

_reset_indent() {
	unset _LOG_INDENT
}

_log_to_file() {
	if [ $_NON_INTERACTIVE ] || [ $_LOGFILE ]; then
		if [ $_CONF_INSTALL_AUDIT -gt 0 ]; then
			printf >&$_NLOG_TARGET '%s %s %s\n' "$1" "$2" "$3"
		else
			printf >&$_NLOG_TARGET '%s\n' "$3"
		fi

		_syslog "$3"
	fi
}

_log_to_console() {
	[ $_NO_WRITE_STDERR ] && return
	_is_open $_LOG_TARGET || return

	[ $_NON_INTERACTIVE ] && [ -z $_LOGFILE ] && return

	if [ $_CONF_INSTALL_AUDIT -gt 0 ]; then
		printf >&$_LOG_TARGET '\033[%s%s \033[0m%s %s\n' "$1" "$2" "$3" "$4"
	else
		printf >&$_LOG_TARGET '\033[%s%s \033[0m\n' "$1" "$4"
	fi
}

_is_open() {
	(: >&"$1") 2>/dev/null
}

_log_app_init() {
	_log_level=debug
	[ $_NON_INTERACTIVE ] && {
		if [ $(basename $0 | grep -c '^_') -eq 0 ]; then
			_log_level=info
		fi
	}

	_log_app init
}

_log_app() {
	_$_log_level "$_APPLICATION_NAME:$_APPLICATION_CMD:$_APPLICATION_VERSION $_APPLICATION_BUILD_DATE / $_APPLICATION_INSTALL_DATE - $1 ($$)"
}
