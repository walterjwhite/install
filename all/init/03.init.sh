trap _on_exit INT 0 1 2 3 4 6 15

_init_logging
_init_application_context

_debug "REMAINING ARGS: $*"

_log_app_init
_init_pager

_waiter

_has_required_conf
