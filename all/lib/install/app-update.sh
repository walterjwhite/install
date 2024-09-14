_is_latest() {
	if [ ! -e $_INSTALL_LIBRARY_PATH/$1 ]; then
		return 1
	fi

	if [ ! -e $_INSTALL_LIBRARY_PATH/$1/.metadata ]; then
		return 1
	fi

	_INSTALLED_APPLICATION_GIT_URL=$(grep _APPLICATION_GIT_URL $_INSTALL_LIBRARY_PATH/$1/.metadata | cut -f2 -d= | tr -d '"')
	_LATEST_APPLICATION_VERSION=$(git ls-remote $_INSTALLED_APPLICATION_GIT_URL 2>/dev/null | head -1 | cut -f1)
	_INSTALLED_APPLICATION_VERSION=$(grep _APPLICATION_VERSION $_INSTALL_LIBRARY_PATH/$1/.metadata | cut -f2 -d. | tr -d '"')

	if [ "$_LATEST_APPLICATION_VERSION" != "$_INSTALLED_APPLICATION_VERSION" ]; then
		return 1
	fi

	return 0
}
