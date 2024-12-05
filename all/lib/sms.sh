_sms() {
	if [ $# -lt 4 ]; then
		_warn "carrier[1], number[2], subject[3], message[4] is required - $# arguments provided"
		return 1
	fi

	local carrier=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
	shift

	local sms_email_domain mms_email_domain

	case $carrier in
	att)
		sms_email_domain=txt.att.net
		mms_email_domain=mms.att.net
		;;
	boost)
		sms_email_domain=smsmyboostmobile.com
		mms_email_domain=myboostmobile.com
		;;
	cricket)
		sms_email_domain=sms.cricketwireless.net
		mms_email_domain=mms.cricketwireless.net
		;;
	sprint)
		sms_email_domain=messaging.sprintpcs.com
		mms_email_domain=pm.sprint.com
		;;
	tmobile)
		sms_email_domain=tmomail.net
		mms_email_domain=tmomail.net
		;;
	us-cellular)
		sms_email_domain=email.uscc.net
		mms_email_domain=mms.uscc.net
		;;
	verizon)
		sms_email_domain=vtext.com
		mms_email_domain=vzwpix.com
		;;
	virgin)
		sms_email_domain=vmobl.com
		mms_email_domain=vmpix.com
		;;
	*)
		_error "Unsupported carrier: $carrier"
		;;
	esac

	_mail "$1@$sms_email_domain" "$2" "$3"
}
