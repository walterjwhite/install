_app_is_shell_script() {
	case $1 in
	*.sh)
		return 0
		;;
	esac

	if [ $(head -1 $1 | $_CONF_INSTALL_GNU_GREP -Pc 'sh$') -gt 0 ]; then
		return 0
	fi

	return 1
}
