#!/bin/sh

tty >/dev/null
_NON_INTERACTIVE=$?

optionalInclude() {
	if [ -e $1 ]; then
		. $1
	else
		warn "$1 does NOT exist"
	fi
}

exitWithError() {
	_ERROR=$2

	if [ $_NON_INTERACTIVE -eq 0 ]; then
		echo >&2 -e "\e[1;31m$1\e[0m"
	else
		logger -i -t "ERR($0): $1"
	fi

	exit $2
}

exitSuccess() {
	if [ $_NON_INTERACTIVE -eq 0 ]; then
		echo -e "\e[1;32m$1\e[0m"
	else
		logger -i -t "SCS($0): $1"
	fi

	exit 0
}

warn() {
	if [ $_NON_INTERACTIVE -eq 0 ]; then
		echo >&2 -e "\e[1;33m$1\e[0m"
	else
		logger -i -t "WRN($0): $1"
	fi
}

info() {
	if [ $_NON_INTERACTIVE -eq 0 ]; then
		echo >&2 -e "\e[1;36m$1\e[0m"
	else
		logger -i -t "INF($0): $1"
	fi
}

_DATE_FORMAT="%Y/%m/%d %H:%M:%S"
debug() {
	if [ -n "$_DEBUG" ]; then
		if [ $_NON_INTERACTIVE -eq 0 ]; then
			echo >&2 -e "$(date "+$_DATE_FORMAT") \e[35m$1\e[0m"
		else
			logger -i -t "DBG($0): $1"
		fi
	fi
}

_require() {
	if [ -z "$1" ]; then
		exitWithError "$2 required" $3
	fi
}

_read_if() {
	if [ $_NON_INTERACTIVE -eq 0 ]; then
		echo >&2 -e "\e[1;3;34m${1}\e[0m ${3}"
		read $2
	else
		exitWithError "Running in non-interactive mode and user input was requested" 10
	fi
}

_() {
	if [ -z "$_DRY_RUN" ]; then
		"$@"

		local _exitStatus=$?
		if [ "$_exitStatus" -gt "0" ]; then
			if [ -n "$_ON_FAILURE" ]; then
				$_ON_FAILURE
				return
			fi

			if [ -z "$WARN_ON_ERROR" ]; then
				exitWithError "Previous cmd failed" $_exitStatus
			else
				warn "Previous cmd failed - $@ - $_exitStatus"
			fi
		fi
	else
		info "$@"
	fi
}

_in_data_path() {
	return $(pwd | grep -c $_DATA_PATH)
}

debug "Application Name: $_APPLICATION_NAME:$_APPLICATION_VERSION" "$_APPLICATION_BUILD_DATE / $_APPLICATION_INSTALL_DATE @ $_APPLICATION_DATA_PATH"

if [ -n "$_DEBUG" ]; then
	set -x
fi
