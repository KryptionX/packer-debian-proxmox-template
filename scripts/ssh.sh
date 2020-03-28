#!/bin/sh -eux

cp --preserve /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +"%Y.%m.%d")

sed -i -r -e '/^#|^$/ d' /etc/ssh/sshd_config

cat <<EOF > /etc/ssh/sshd_config
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key

KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256

Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr

MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com

AuthenticationMethods publickey
LogLevel VERBOSE
Subsystem sftp  /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO
PermitRootLogin no
UsePrivilegeSeparation sandbox
Protocol 2
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes

PubkeyAuthentication yes
Port 22
EOF