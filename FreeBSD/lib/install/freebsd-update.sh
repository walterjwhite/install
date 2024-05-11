_freebsd_update() {
	local freebsd_update_configuration_file=$freebsd_root/etc/freebsd-update.conf
	local freebsd_update_options

	[ -n "$$freebsd_root" ] && freebsd_update_options="-b $_JAIL_ZFS_MOUNTPOINT/$_JAIL_NAME"

	grep -qs '^CreateBootEnv yes' $freebsd_update_configuration_file || {
		printf '# disable creation of boot environments, will be handled automatically via system-maintenance app\n' >>$freebsd_update_configuration_file
		printf 'CreateBootEnv no\n' >>$freebsd_update_configuration_file
	}

	env PAGER=cat freebsd-update $freebsd_update_options "$@" --not-running-from-cron fetch install
}
