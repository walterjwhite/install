import time.sh

_pkg_update() {
	_pkg_bootstrap
	_USE_SUDO=1 _PRESERVE_ENV=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "FreeBSD pkg upgrade" pkg $_PKG_OPTIONS upgrade -yq $@ >/dev/null
}

_pkg_install() {
	_pkg_bootstrap
	_USE_SUDO=1 _PRESERVE_ENV=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "FreeBSD pkg install" pkg $_PKG_OPTIONS install -yq $@ >/dev/null
}

_pkg_uninstall() {
	_pkg_bootstrap
	_USE_SUDO=1 _PRESERVE_ENV=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "FreeBSD pkg uninstall" pkg $_PKG_OPTIONS delete -yq $@ >/dev/null
}

_pkg_is_installed() {
	_pkg_bootstrap
	pkg $_PKG_OPTIONS info -e $1 2>/dev/null
}

_pkg_bootstrap() {
	[ $_PKG_BOOTSTRAPPED ] && return

	ASSUME_ALWAYS_YES=yes
	_PKG_BOOTSTRAPPED=1

	if [ -n "$_ROOT" ] && [ "$_ROOT" != "/" ]; then
		_pkg_cache_already_mounted || _pkg_cache_mount
		_PKG_OPTIONS="-r $_ROOT"
	fi

	_pkg_enable_proxy

	_USE_SUDO=1 _PRESERVE_ENV=1 _timeout $_CONF_INSTALL_STEP_TIMEOUT "FreeBSD pkg bootstrap" pkg $_PKG_OPTIONS update -q
}

_pkg_cache_already_mounted() {
	mount | awk {'print$3'} | grep -q "$_ROOT/var/cache/pkg$"
}

_pkg_cache_mount() {
	_sudo mkdir -p $_ROOT/var/cache/pkg

	_info "Mounting host's package cache"
	_sudo mount -t nullfs /var/cache/pkg $_ROOT/var/cache/pkg || {
		_warn "Error mounting host's package cache"
		_warn "pkg cache mounts: $(mount | awk {'print$3'} | grep \"^$_ROOT/var/cache/pkg$\")"
		_warn "mounts: $(mount | awk {'print$3'})"
		return 1
	}

	_defer _pkg_cache_umount

	_info "Mounted host's package cache"
}

_pkg_cache_umount() {
	umount $_ROOT/var/cache/pkg
}

_pkg_bootstrap_platform() {
	_pkg_bootstrap
}

_pkg_bootstrap_is_pkg_available() {
	return 0
}

_pkg_enable_proxy() {
	[ -z "$http_proxy" ] && return 1
	[ $_PKG_PROXY_ENABLED ] && return 2

	_PKG_PROXY_ENABLED=1
	_defer _pkg_disable_proxy
	_warn "[install] Configuring pkg to use an HTTP proxy: $http_proxy"

	local _updated_pkg_conf=$(mktemp)
	if [ -e $_ROOT/usr/local/etc/pkg.conf ]; then
		grep -v '^pkg_env' $_ROOT/usr/local/etc/pkg.conf >$_updated_pkg_conf
		mv $_updated_pkg_conf $_ROOT/usr/local/etc/pkg.conf
	fi

	mkdir -p $_ROOT/usr/local/etc
	printf 'pkg_env: { http_proxy: "%s"}\n' "$http_proxy" >>$_ROOT/usr/local/etc/pkg.conf
}

_pkg_disable_proxy() {
	[ -z "$http_proxy" ] && return 1

	unset _PKG_PROXY_ENABLED
	_warn "[freebsd-installer] Disabling HTTP proxy: $http_proxy"
	$_CONF_INSTALL_GNU_SED -i "s/^pkg_env/#pkg_env/" $_ROOT/usr/local/etc/pkg.conf
}

_pkg_setup_ssh_package_cache() {
	[ $# -lt 1 ] && _error "SSH host is required to setup ssh cache"

	_pkg_install fusefs-sshfs || _error "Error installing fusefs-sshfs"

	kldload /boot/kernel/fusefs.ko

	mv /var/cache/pkg /var/cache/pkg.local
	mkdir -p /var/cache/pkg

	sshfs -o StrictHostKeyChecking=no :/var/cache/pkg /var/cache/pkg

	mv -f /var/cache/pkg.local/* /var/cache/pkg
	rm -rf /var/cache/pkg.local

	_defer _cleanup_package_cache $1
}

_pkg_cleanup_ssh_package_cache() {
	umount /var/cache/pkg
	kldunload fusefs
}
