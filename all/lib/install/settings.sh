_settings_init() {
	if [ -z "$_ROOT" ]; then
		_ROOT=/
	fi

	_ROOT=$(_readlink $_ROOT)
	_info "Using root directory: $_ROOT"

	_INSTALL_BIN_PATH=$(_USE_SUDO=1 _readlink $_ROOT/$_CONF_INSTALL_BIN_PATH)
	_INSTALL_CONFIG_PATH=$(_USE_SUDO=1 _readlink $_ROOT/$_CONF_INSTALL_CONFIG_PATH)
	_INSTALL_DATA_PATH=$(_USE_SUDO=1 _readlink $_ROOT/$_CONF_INSTALL_DATA_PATH)
	_INSTALL_LIBRARY_PATH=$(_USE_SUDO=1 _readlink $_ROOT/$_CONF_INSTALL_LIBRARY_PATH)

	_APPLICATION_METADATA_PATH=$_INSTALL_LIBRARY_PATH/install/.metadata

	_configure $_APPLICATION_METADATA_PATH

	if [ "$_ROOT" != "/" ]; then
		unset $(env | grep _BOOTSTRAP | cut -f1 -d=)
	fi
}

_application_settings() {
	_TARGET_APPLICATION_VERSION=$(git branch --no-color --show-current).$(git rev-parse HEAD)
	_TARGET_APPLICATION_BUILD_DATE=$(git log --format=%cd -1)

	_TARGET_APPLICATION_INSTALL_DATE=$(date +"%a %b %d %H:%M:%S %Y %z")

	_TARGET_APPLICATION_DATA_PATH=$_INSTALL_DATA_PATH/$_TARGET_APPLICATION_NAME
	_TARGET_APPLICATION_CONFIG_PATH="$_INSTALL_CONFIG_PATH/$_TARGET_APPLICATION_NAME"
	_TARGET_APPLICATION_METADATA_PATH=$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.metadata

	_TARGET_APPLICATION_GIT_URL=$(git remote -v | awk {'print$2'} | head -1)

	mkdir -p $_INSTALL_DATA_PATH/install $_CONF_INSTALL_DATA_PATH $_TARGET_APPLICATION_DATA_PATH

	_configure $_TARGET_APPLICATION_CONFIG_PATH
}

_application_defaults() {
	local default_file
	for default_file in $(find $1/defaults -type f 2>/dev/null); do
		_configure $default_file
	done
}
