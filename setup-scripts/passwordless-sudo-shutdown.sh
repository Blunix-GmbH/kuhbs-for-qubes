# Setup passwordless sudo shutdown -h now. This is used to launch applications and shutdown the machine after the application is closed



apt-get --yes install sudo

cat << EOF | tee /etc/sudoers.d/99-kuhbs
user ALL=(ALL:ALL) NOPASSWD: /sbin/shutdown
EOF
