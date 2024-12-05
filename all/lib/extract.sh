_extract() {
	if [ $# -lt 2 ]; then
		_warn "Expecting 2 arguments, source file, and target to extract to"
		return 1
	fi

	_info "### Extracting $1"

	local _extension=$(printf '%s' "$1" | $_CONF_INSTALL_GNU_GREP -Po "\\.(tar\\.gz|tar\\.bz2|tbz2|tgz|zip|tar\\.xz)$")

	case $_extension in
	".tar.gz" | ".tgz")
		tar zxf $1 -C $2
		;;
	".zip")
		unzip -q $1 -d $2
		;;
	".tar.bz2" | ".tbz2")
		tar jxf $1 -C $2
		;;
	".tar.xz")

		xz -dc $1 | tar xf -C $2
		;;
	*)
		_warn "extension unsupported - $_extension $1"
		return 2
		;;
	esac
}
