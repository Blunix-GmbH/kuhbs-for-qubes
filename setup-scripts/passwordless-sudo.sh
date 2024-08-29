# Setup passwordless sudo



apt-get --yes install sudo

usermod --append --groups sudo user

cat << EOF | tee /etc/sudoers
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
root	ALL=(ALL:ALL) ALL
user	ALL=(ALL) NOPASSWD: ALL
EOF
