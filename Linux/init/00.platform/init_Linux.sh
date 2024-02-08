_SUB_PLATFORM=$(grep '^NAME=.*' /etc/os-release | sed -e 's/^NAME=//' | tr -d '"')

case $_SUB_PLATFORM in
Ubuntu | Debian)
	_INSTALL_INSTALLER=apt
	;;
CentOS | RedHat)
	_INSTALL_INSTALLER=yum
	;;
*)
	_error "Unsupported Linux Distribution: $_SUB_PLATFORM"
	;;
esac
