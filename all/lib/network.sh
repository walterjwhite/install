_online() {
	curl --connect-timeout $_CONF_INSTALL_NETWORK_TEST_TIMEOUT -s $_CONF_INSTALL_NETWORK_TEST_TARGET >/dev/null 2>&1 || return 1
}
