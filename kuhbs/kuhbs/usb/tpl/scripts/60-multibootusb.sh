# Setup multibootusb
# https://github.com/mbusb/multibootusb/releases/download/v9.2.0/python3-multibootusb_${multibootusb_version}.deb


declare -r multibootusb_version_short=9.2.0
declare -r multibootusb_version_long=9.2.0-1


wget https://github.com/mbusb/multibootusb/releases/download/v${multibootusb_version_short}/python3-multibootusb_${multibootusb_version_long}_all.deb
# This command will fail with package dependency errors
dpkg -i python3-multibootusb_${multibootusb_version_long}_all.deb || true
# This command installs those dependencies
apt-get --yes -f install
