_prepare_ssh_conf() {
	_sudo mkdir -p $1/.ssh/socket
	_sudo chmod 700 $1/.ssh/socket

	printf 'StrictHostKeyChecking no\n' | _sudo tee -a $1/.ssh/config >/dev/null

	[ -n "$_HOST_IP" ] && _ssh_init_bastion_host $1

	if [ -e /tmp/HOST-SSH ]; then
		_info "Copying host ssh -> $1/.ssh"

		_sudo cp /tmp/HOST-SSH/id* $1/.ssh
	fi

	[ "$2" != "root" ] && _sudo chown -R $2:$2 $1/.ssh
}

_ssh_init_bastion_host() {
	_info "Setting up SSH Bastion host: $1"

	printf 'Host host-proxy\n' | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' Hostname %s\n' "$_HOST_IP" | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | _sudo tee -a $1/.ssh/config >/dev/null

	printf 'Host git\n' | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' ProxyJump host-proxy:%s\n' $_SSH_HOST_PORT | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | _sudo tee -a $1/.ssh/config >/dev/null

	printf 'Host freebsd-package-cache\n' | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' ProxyJump host-proxy:%s\n' $_SSH_HOST_PORT | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | _sudo tee -a $1/.ssh/config >/dev/null

	printf 'Host %s\n' "$_PACKAGE_CACHE" | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' ProxyJump host-proxy:%s\n' $_SSH_HOST_PORT | _sudo tee -a $1/.ssh/config >/dev/null
	printf ' User root\n' | _sudo tee -a $1/.ssh/config >/dev/null

	if [ "$_PACKAGE_CACHE" != "$_GIT_MIRROR" ]; then
		printf 'Host %s\n' "$_GIT_MIRROR" | _sudo tee -a $1/.ssh/config >/dev/null
		printf ' ProxyJump host-proxy\n' | _sudo tee -a $1/.ssh/config >/dev/null
		printf ' User root\n' | _sudo tee -a $1/.ssh/config >/dev/null
	fi

	_sudo chmod 600 $1/.ssh/config
}
