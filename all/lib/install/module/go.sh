_go_bootstrap() {
	_go_bootstrap_is_go_available || {
		_go_bootstrap_platform
		_go_bootstrap_is_go_available || _GO_DISABLED=1
	}

	_go_setup_proxy
}

_go_bootstrap_is_go_available() {
	which go >/dev/null 2>&1
}

_go_install() {
	_USE_SUDO=1 _PRESERVE_ENV=1 GO111MODULE=on _timeout $_CONF_INSTALL_STEP_TIMEOUT "go install" go install $_GO_OPTIONS "$@" || {
		_warn "go install failed: $_GO_OPTIONS $@"
		_warn "  http_proxy: $http_proxy"
		_warn "  git  proxy: $(git config --global http.proxy)"
	}
}

_go_update() {
	:
}

_go_uninstall() {
	_USE_SUDO=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "go uninstall" go uninstall "$@"
}

_go_is_installed() {
	return 1
}

_go_is_file() {
	return 1
}

_go_setup_proxy() {
	if [ -n "$http_proxy" ]; then
		_warn "Configuring git to use an HTTP proxy: $http_proxy"

		git config --global http.proxy $http_proxy
		git config --global https.proxy $http_proxy


		_defer _go_clear_proxy
	fi
}

_go_clear_proxy() {
	_warn "Reverting git HTTP proxy: $http_proxy"

	git config --unset --global http.proxy
	git config --unset --global https.proxy
}
