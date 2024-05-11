_is_feature() {
	printf '%s' $_SETUP | grep -c /feature/
}

_disable_feature() {
	if [ -z "$_FEATURE_DISABLED" ]; then
		_warn "Error installing feature: $_FEATURE ($1)"
	fi

	printf '%s\n' $(_feature_key $1)_DISABLED=1 | _metadata_write
}

_is_feature_enabled() {
	local _feature_key=$(_feature_key $1)


	if [ $(env | grep -c "^${_feature_key}_DISABLED=1$") -gt 0 ]; then
		_warn "$1 is disabled"
		return 1
	fi

	return 0
}

_feature_key() {
	printf '%s\n' "_FEATURE_${1}" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}
