_system_zfs_pool() {
	zfs list -H | awk {'print$1'} | grep ROOT$ | sed -e 's/\/ROOT//'
}

_io() {
	zpool iostat -Hyqp $(_system_zfs_pool) 1 $_CONF_INSTALL_IOSTAT_DURATION |
		awk {'print$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16'} |
		tr ' ' '+' |
		tr '\n' '+' |
		sed -e 's/+$//' |
		bc
}
