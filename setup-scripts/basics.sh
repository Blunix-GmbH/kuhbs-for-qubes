# setup basics for all VMs



# Fix locale
DEBIAN_FRONTEND=noninteractive apt-get --yes install locales-all
locale-gen en_US.UTF-8

# Install apt packages
apt-get --yes install \
  apt-file \
  curl \
  wget \
  locate \
  xfce4-terminal \
  snapd

# Update apt-file cache
apt-file update

# Configure X11 Xressources file
mv /home/user/QubesIncoming/dom0/common-templates/etc/X11/Xressources /etc/X11/Xressources

# Setup root and user config for xfce4-terminal
mkdir -p /root/.config/xfce4/terminal/
mv /home/user/QubesIncoming/dom0/common-templates/root/.config/xfce4/terminal/terminalrc /root/.config/xfce4/terminal/terminalrc

mkdir -p /home/user/.config/xfce4/terminal/
mv /home/user/QubesIncoming/dom0/common-templates/home/user/.config/xfce4/terminal/terminalrc /home/user/.config/xfce4/terminal/terminalrc
