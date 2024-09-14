_update_remove_commented_code() {
	$_CONF_INSTALL_GNU_SED -i '/^[[:space:]]*# TODO: .*$/d' $1

	$_CONF_INSTALL_GNU_SED -i '/^[[:space:]]*# .*$/d' $1

	$_CONF_INSTALL_GNU_SED -i '/^$/d' $1
}

_update_constants() {
	case $1 in
	*/artifacts/install/*)
		_debug "Bypassing update"
		return 1
		;;
	*)
		_debug "Updating constants: $1"
		;;
	esac

	$_CONF_INSTALL_GNU_SED -i "s/_LIBRARY_APPLICATION_PATH_/$_SED_LIBRARY_PATH\/$_TARGET_APPLICATION_NAME/g" $1

	$_CONF_INSTALL_GNU_SED -i "s/_LIBRARY_PATH_/$_SED_LIBRARY_PATH/g" $1
	$_CONF_INSTALL_GNU_SED -i "s/_APPLICATION_NAME_/$_TARGET_APPLICATION_NAME/g" $1
	$_CONF_INSTALL_GNU_SED -i "s/_APPLICATION_VERSION_/$_TARGET_APPLICATION_VERSION/g" $1
}
