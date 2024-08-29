# Update apt
apt update
DEBIAN_FRONTEND=noninteractive apt-get --yes upgrade
DEBIAN_FRONTEND=noninteractive apt-get --yes dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get --yes full-upgrade
DEBIAN_FRONTEND=noninteractive apt-get --yes autoremove
