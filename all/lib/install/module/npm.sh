_npm_bootstrap() {
	_npm_bootstrap_is_npm_available || {
		_npm_bootstrap_platform
		_npm_bootstrap_is_npm_available || _NPM_DISABLED=1
	}

	_npm_setup_proxy
}

_npm_bootstrap_is_npm_available() {
	which npm >/dev/null 2>&1
}

_npm_install() {
	local npm_package
	for npm_package in "$@"; do
		_npm_is_installed $npm_package || _sudo npm install -s -g "$npm_package"
	done
}

_npm_uninstall() {
	_sudo npm uninstall -s -g "$@"
}

_npm_is_installed() {
	npm list -g $1 >/dev/null
}

_npm_is_file() {
	return 1
}

_npm_setup_proxy() {
	if [ -n "$http_proxy" ]; then
		_warn "Configuring NPM to use an HTTP proxy: $http_proxy"

		npm config set proxy $http_proxy
		npm config set https-proxy $https_proxy

		_defer _npm_clear_proxy
	fi
}

_npm_clear_proxy() {
	_warn "Reverting NPM HTTP proxy: $http_proxy"

	npm config rm proxy
	npm config rm https-proxy
}
