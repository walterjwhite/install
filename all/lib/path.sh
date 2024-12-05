_in_path() {
	_require "$1" _in_path

	local test_path=$(readlink -f $1)
	readlink -f $PWD | grep -c "^$test_path" >/dev/null 2>&1
}

_in_application_data_path() {
	_in_path $_CONF_INSTALL_APPLICATION_DATA_PATH
}

_in_data_path() {
	_in_path $_CONF_INSTALL_DATA_PATH
}

_remove_empty_directories() {
	find $1 -type d -empty -exec rm -rf {} +
}
