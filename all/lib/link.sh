_link() {
	_sudo ln -s $1 $2

	if [ -n "$_APP_INSTALLATION" ]; then
		printf '%s\n' "$2" | _write "$_INSTALL_LIBRARY_PATH/$_TARGET_APPLICATION_NAME/.files"
	fi
}
