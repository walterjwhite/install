if [ -n "$_REQUIRED_ARGUMENTS" ]; then
	_DISCOVERED_ARGUMENT_COUNT=$(printf '%s' "$_REQUIRED_ARGUMENTS" | sed -e 's/$/\n/' | tr '|' '\n' | wc -l | awk {'print$1'})

	_required_arguments_argument_log_level=debug
	_ACTUAL_ARGUMENT_COUNT=$#
	[ $_ACTUAL_ARGUMENT_COUNT -lt $_DISCOVERED_ARGUMENT_COUNT ] && _required_arguments_argument_log_level=warn

	_$_required_arguments_argument_log_level "Expecting $_DISCOVERED_ARGUMENT_COUNT, received $# arguments"

	_INDEX=1
	_ARGUMENT_LOG_LEVEL=info
	while [ $_INDEX -le $_DISCOVERED_ARGUMENT_COUNT ]; do
		_ARGUMENT_NAME=$(printf '%s' "$_REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${_INDEX}p | sed -e 's/:.*$//')
		_ARGUMENT_MESSAGE=$(printf '%s' "$_REQUIRED_ARGUMENTS" | tr '|' '\n' | sed -n ${_INDEX}p | sed -e 's/^.*://')

		if [ -z "$1" ]; then
			_$_required_arguments_argument_log_level "$_INDEX:$_ARGUMENT_MESSAGE was not provided"
		else
			_$_required_arguments_argument_log_level "$_INDEX:$_ARGUMENT_NAME=$1"
			export $_ARGUMENT_NAME="$1"
			shift
		fi

		_INDEX=$(($_INDEX + 1))
	done

	[ $_ACTUAL_ARGUMENT_COUNT -lt $_DISCOVERED_ARGUMENT_COUNT ] && _error "Missing arguments"
	unset _INDEX _ARGUMENT_NAME _ARGUMENT_MESSAGE _required_arguments_argument_log_level

	_DISCOVERED_REQUIRED_ARGUMENTS="$_REQUIRED_ARGUMENTS"
	unset _REQUIRED_ARGUMENTS
else
	_debug "NO _REQUIRED_ARGUMENTS args"

	unset _DISCOVERED_REQUIRED_ARGUMENTS _DISCOVERED_ARGUMENT_COUNT
fi
