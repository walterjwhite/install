case $_DETECTED_PLATFORM in
$_PLATFORM) ;;

Apple | FreeBSD | Linux | Windows)
	_error "Please use the appropriate platform-specific installer ($_DETECTED_PLATFORM)"
	;;
*)
	_error "Unsupported platform ($_DETECTED_PLATFORM)"
	;;
esac
