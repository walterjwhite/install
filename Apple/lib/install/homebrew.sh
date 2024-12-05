_homebrew_bootstrap_is_homebrew_available() {
	which brew >/dev/null 2>&1
}

_homebrew_bootstrap_platform() {
	if [ ! -e $_CONF_INSTALL_HOMEBREW_CMD ]; then
		_timeout $_CONF_INSTALL_STEP_TIMEOUT "homebrew bootstrap platform" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

		printf 'eval "$(%s shellenv)"\n' "$_CONF_INSTALL_HOMEBREW_CMD" >>~/.zprofile
		eval "$($_CONF_INSTALL_HOMEBREW_CMD shellenv)"

		return
	fi

	_warn "Homebrew appears to already be installed"
}

_homebrew_bootstrap() {
	_homebrew_bootstrap_platform
}

_homebrew_install() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "homebrew install" brew install $@
}

_homebrew_uninstall() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "homebrew uninstall" brew uninstall $@
}

_homebrew_bootstrap_uninstall() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "homebrew bootstrap uninstall" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

	_sudo rm -rf /opt/homebrew
}

_homebrew_update() {
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "homebrew update [brew]" brew update
	_timeout $_CONF_INSTALL_STEP_TIMEOUT "homebrew update" brew upgrade $@
}

_homebrew_is_installed() {
	brew ls --versions "$1" >/dev/null
	if [ $? -gt 0 ]; then
		return 1
	fi

	brew outdated "$1" >/dev/null
}

_homebrew_is_not_package() {
	printf '%s' "$1" | grep -c ' ' >/dev/null
}
