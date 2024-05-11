if [ "$(whoami)" = "root" ]; then
	if [ -n "$_SUDO_CMD" ]; then
		_SUDO_NORMAL_USER_CMD="$_SUDO_CMD -u $USER"
	fi
fi
