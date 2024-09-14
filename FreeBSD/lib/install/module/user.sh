import ssh.sh

_user_bootstrap() {
	_sudo mkdir -p /root/.ssh/socket
	_sudo chmod -R 700 /root/.ssh/socket

	app-install configuration
}

_user_install() {
	_users_add "$1"
}

_user_uninstall() {
	. "$1"

	_require "$username" "username"
	rmuser -y $username
}

_user_is_installed() {
	:
}

_user_enabled() {
	return 0
}

_users_add_argument() {
	if [ -n "$2" ]; then
		user_options="$user_options $1 $2"
	fi
}

_users_add() {
	. $1

	if [ "root" != "$username" ]; then
		_sudo pw user show $username >/dev/null 2>&1 || {
			_info "### Add User: $1: $username"

			user_options="-n $username -m"

			_users_add_argument "-g" "$gid"
			_users_add_argument "-G" "$grouplist"
			_users_add_argument "-s" "$shell"
			_users_add_argument "-u" "$uid"

			_sudo pw useradd $user_options
		}
	else
		_info "# Setting shell to $shell for root"
		_sudo chsh -s "$shell"
	fi

	if [ -n "$password" ]; then
		_info "# Setting password $shell for $username"
		_sudo chpass -p "$password" $username
	fi

	_users_configure
	_users_cleanup
}

_users_get_data() {
	printf '%s\n' "$username" | tr ' ' '\n'
}

_users_cleanup() {
	unset user_options username gid grouplist shell uid password system
}

_users_configure() {
	local user_home=$(grep "^$username:" /etc/passwd | cut -f6 -d':')

	sudo=$SUDO_CMD _prepare_ssh_conf $user_home $username

	local original_pwd=$PWD
	cd /tmp

	if [ -n "$system" ]; then
		_warn "$username is a system user, bypassing configuration"
	else
		_warn "_CONF_FREEBSD_INSTALLER_HOSTNAME:$_CONF_FREEBSD_INSTALLER_HOSTNAME"

		_WARN_ON_ERROR=1 _NON_INTERACTIVE=1 _FREEBSD_INSTALLER=1 _NO_WRITE_STDERR=1 _SUDO_REQUIRED=1 _ _sudo \
			--preserve-env=_CONF_GIT_MIRROR,_WARN_ON_ERROR,_LOG_TARGET,_NON_INTERACTIVE,_CONF_FREEBSD_INSTALLER_HOSTNAME,_NO_WRITE_STDERR,http_proxy,https_proxy \
			-H -u $username conf restore || _user_configure_debug
	fi

	cd $original_pwd
}

_user_configure_debug() {
	_warn "Error restoring configuration for $username"
	cat $user_home/.ssh/id_ecdsa.pub
	cat $user_home/.ssh/authorized_keys
	cat $user_home/.ssh/config
}
