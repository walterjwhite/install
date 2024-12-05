_variable_is_set() {
	[ $(env | grep "^$1=.*$" | wc -l) -gt 0 ] && return 0

	return 1
}

_has_required_conf() {
	if [ -n "$_REQUIRED_APP_CONF" ]; then
		for _REQUIRED_APP_CONF_ITEM in $(printf '%s' "$_REQUIRED_APP_CONF" | sed -e 's/$/\n/' | tr '|' '\n'); do
			_variable_is_set $_REQUIRED_APP_CONF_ITEM || {
				_warn "$_REQUIRED_APP_CONF_ITEM is unset"
				_MISSING_REQUIRED_CONF=1
			}
		done

		if [ -n "$_MISSING_REQUIRED_CONF" ]; then
			_error "Required configuration is missing, please refer to above error(s)"
		fi
	fi
}
