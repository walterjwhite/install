_declared_static_functions() {
	[ -z "$1" ] && return 1

	$_CONF_INSTALL_GNU_GREP -Po '^_[_a-zA-Z0-9]+\(\) \{$' $1 | sed -e 's/() {$//'
}

_is_function_used() {
	[ -z "$1" ] && return 1
	[ -z "$2" ] && return 2

	grep -cq "$1 " $2
}

_remove_function() {
	[ -z "$1" ] && return 1
	[ -z "$2" ] && return 2

	_detail "$removing $1 from $2"

	local start=$(grep -nm 1 "^$1() {" $2 | sed -e 's/\:.*$//')
	local end=$(tail -n +$start $2 | grep -nm 1 '^}$' | sed -e 's/\:.*$//')
	end=$(($start + $end - 1))

	_detail "$start:$end"
	local newf=$(mktemp)

	cp $2 $newf
	$_CONF_INSTALL_GNU_SED -i "${start},${end}d" $newf
}

_remove_unused_functions() {
	local file=$1
	shift

	local function_name
	for function_name in $(_declared_static_functions $file); do
		_is_function_used $function_name $file || _remove_function $function_name $file
	done
}
