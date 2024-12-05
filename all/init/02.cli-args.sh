for _ARG in "$@"; do
	case $_ARG in
	-h | --help)
		_print_help_and_exit
		;;
	-kill-all)
		_kill_all

		_success "Killed all"
		;;
	-kill-all-group)
		_kill_all_group

		_success "Killed all group"
		;;
	-kill=*)
		_kill ${_ARG#*=}

		_success "Killed ${_ARG#*=}"
		;;
	-lr)
		_list

		_success "listed running processes"
		shift
		;;
	-lg)
		_list_group
		_success "listed running processes"
		;;
	-w=*)
		_WAITER_PID="${1#*=}"
		shift
		;;
	-w)
		_CONF_INSTALL_WAITER_LEVEL=_info
		_WAITEE=1

		shift
		;;
	-conf-* | -[a-z0-9][a-z0-9][a-z0-9]*)
		_configuration_name=${_ARG#*-}
		_configuration_name=${_configuration_name%%=*}

		if [ $(printf '%s' "$_configuration_name" | grep -c '_') -eq 0 ]; then
			if [ $(printf '%s' "$_configuration_name" | grep -c '^conf') -gt 0 ]; then
				_configuration_name=$(printf '%s' "$_configuration_name" | sed -e "s/-/-$_APPLICATION_NAME-/")
			else
				_configuration_name=$(printf '%s' "$_configuration_name" | sed -e "s/^/$_APPLICATION_NAME-/")
			fi
		fi

		_configuration_name=$(printf '%s' $_configuration_name | tr '-' '_' | tr '[:lower:]' '[:upper:]')
		if [ $(printf '%s' "$_ARG" | grep -c '=') -eq 0 ]; then
			_configuration_value=1
		else
			_configuration_value=${_ARG#*=}
		fi

		export _$_configuration_name="$_configuration_value"
		unset _configuration_name
		shift
		;;
	*)
		break
		;;
	esac
done
