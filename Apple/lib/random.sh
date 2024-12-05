_random() {
	local random_length=$1

	openssl rand -base64 $random_length
}
