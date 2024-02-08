case $_DETECTED_PLATFORM in
$_PLATFORM) ;;

Darwin | FreeBSD | Linux | MINGW64_NT-*)
	_error "Please use the appropriate platform-specific installer ($_DETECTED_PLATFORM)"
	;;
*)
	_error "Unsupported platform"
	;;
esac
