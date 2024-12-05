_environment_filter() {
	grep '^_CONF_'
}

_environment_dump() {
	if [ -z "$_APPLICATION_PIPE_DIR" ]; then
		return
	fi

	if [ -z "$_ENVIRONMENT_FILE" ]; then
		_ENVIRONMENT_FILE=$_APPLICATION_PIPE_DIR/environment
	fi

	mkdir -p $(dirname $_ENVIRONMENT_FILE)
	env | _environment_filter | sort -u | grep -v '^$' | sed -e 's/=/="/' -e 's/$/"/' >>$_ENVIRONMENT_FILE
}

_environment_load() {
	if [ -n "$_ENVIRONMENT_FILE" ]; then
		if [ -e "$_ENVIRONMENT_FILE" ]; then
			. $_ENVIRONMENT_FILE 2>/dev/null
		else
			_warn "$_ENVIRONMENT_FILE does not exist!"
		fi
	fi
}
