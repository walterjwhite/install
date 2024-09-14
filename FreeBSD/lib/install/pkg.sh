import time.sh

_pkg_update() {
	_pkg_bootstrap
	_sudo pkg $_PKG_OPTIONS upgrade -yq $@
	_sudo pkg $_PKG_OPTIONS autoremove -yq $@
}

_pkg_install() {
	_pkg_bootstrap
	_sudo pkg $_PKG_OPTIONS install -yq $@
}

_pkg_uninstall() {
	_pkg_bootstrap
	_sudo pkg $_PKG_OPTIONS delete -yq $@
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

	_sudo pkg $_PKG_OPTIONS update -q
}

_pkg_cache_already_mounted() {
	mount | awk {'print$3'} | grep -q "$_ROOT/var/cache/pkg$"
}

_pkg_cache_mount() {
	[ -e /sbin/mount_nullfs ] || return 1

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
