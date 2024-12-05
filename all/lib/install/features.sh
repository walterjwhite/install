_features() {
	if [ ! -e $1 ]; then
		if [ -z "$_WARN" ]; then
			_warn "No features to install"
		fi

		return 1
	fi

	_info "Installing ${_FEATURE_MESSAGE}features"
	local feature
	for feature in $(_features_find $1 | sort -u); do
		_FEATURE_NAME=$(printf '%s' $feature | sed -e 's/\.feature/\.feature\n/g' | $_CONF_INSTALL_GNU_GREP -Po '/[a-zA-Z0-9-_]*.feature$' | sed -e 's/^\///' -e 's/\.feature$//' | tr '\n' '_' | sed -e 's/_$//')

		_application_defaults $feature

		_is_feature_enabled $_FEATURE_NAME || {
			_FEATURE_DISABLED=1 _disable_feature $_FEATURE_NAME
			_features_unset
			continue
		}

		_feature $feature || {
			_disable_feature $_FEATURE_NAME
			_features_unset
			continue
			feature_error=1
		}

		_FEATURE_MESSAGE="children " _WARN=0 _features $feature/feature
		_features_unset
	done
}

_features_unset() {
	unset _FEATURE_NAME _FEATURE_DISABLED
}

_features_find() {
	if [ -z "$_FEATURE_MESSAGE" ]; then
		find $1 -type d \( -name '*.feature' -and ! -path '*/*.feature/*' \)
	else
		find $1 -type d -name '*.feature' -and ! -name "$1"
	fi
}

_feature() {
	_detail $_FEATURE_NAME

	_install $1 || return $?
	_feature_setup $1 || return $?
}

_feature_setup() {
	local setup_script
	for setup_script in $(find $1 -type f \( -path "$1/setup/*" \) | sort -u); do
		_setup_run_script $setup_script || return 1
	done
}
