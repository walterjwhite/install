_send_teams_message() {
	printf '%s\n' "$1" | tr '|' '\n' |
		xargs -P$_CONF_INSTALL_TEAMS_MESSAGE_PARALLELIZATION -I {} \
			curl -H 'Content-Type: application/json' -d "{\"text\": \"$2\"}" {} >/dev/null
}
