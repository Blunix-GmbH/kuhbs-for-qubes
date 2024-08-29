#!/bin/bash
#
# Setup dnscrypt proxy

set -e -x



## INSTALL DNSCRYPT-PROXY ##

# Install packages from testing repo (currently no dnscrypt-proxy package for deb stable)
echo "deb http://deb.debian.org/debian/ testing main" | tee /etc/apt/sources.list.d/testing.list


# Pin testing repo
cat << 'EOF' | tee /etc/apt/preferences.d/pinning.pref
Package: *
Pin: release a=stable
Pin-Priority: 900

Package: *
Pin: release a=testing
Pin-Priority: 500

Package: *
Pin: release a=unstable
Pin-Priority: 100
EOF


# Install dnscrypt-proxy
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y install dnscrypt-proxy


# Setup config file
mv -v /home/user/QubesIncoming/dom0/kuh-templates/dnscrypt-proxy/dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
chown -v -R _dnscrypt-proxy:root /etc/dnscrypt-proxy/
find /etc/dnscrypt-proxy/ -type d -exec chmod -v -R 550 {} \;
find /etc/dnscrypt-proxy/ -type f -exec chmod -v -R 440 {} \;


# Setup systemd service
#mv -v /home/user/QubesIncoming/dom0/kuh-templates/dnscrypt-proxy/dnscrypt-proxy.service /usr/lib/systemd/system/dnscrypt-proxy.service
#systemctl daemon-reload


# Enable systemd service
systemctl enable dnscrypt-proxy.service
systemctl enable dnscrypt-proxy.socket
# Force-set local resolver
set -x -e


# Force-set /etc/resolv.conf
echo 'nameserver 127.0.2.1' > /etc/resolv.conf
chattr +i /etc/resolv.conf



# TODO
exit
## GENRATE BLOCKED DOMAINS LIST ##
# TODO process https://github.com/mullvad/dns-blocklists


# Download and process blocklists for dnscrypt-proxy
process_blocklist() {
    list_category=$1
    mkdir -p /etc/dnscrypt-proxy/blocked-names/$list_category/
    list_url=$2
    list_filename=$(echo $list_url | tr '[:upper:]' '[:lower:]' | sed -e 's@https://@@g' -e 's@/@.@g' -e 's/\%/./g' -e 's/-/./g')
    curl $list_url \
    | sed 's/0.0.0.0//g' \
    | sed 's/127.0.0.1//g' \
    | sed 's/^[[:space:]]\+//g' \
    | sed '/^#/d' \
    | sed 's/#.*//g' \
    | sed 's/ /\n/g' \
    | sed '/./!d' \
    | egrep -v 'localhost|::1|^-$|^--$|::|\[|\]|\||</b></td>' \
    >> /etc/dnscrypt-proxy/blocked-names/$list_category/$list_filename
}

# Custom blacklist
mkdir -p /etc/dnscrypt-proxy/blocked-names/custom/
echo "*google*
*facebook*
*bing*
*instagram*" >> /etc/dnscrypt-proxy/blocked-names/custom/custom.txt

# https://www.github.developerdan.com/hosts
process_blocklist ads      https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt
process_blocklist social   https://www.github.developerdan.com/hosts/lists/facebook-extended.txt
process_blocklist google   https://www.github.developerdan.com/hosts/lists/amp-hosts-extended.txt
process_blocklist hate     https://www.github.developerdan.com/hosts/lists/hate-and-junk-extended.txt
process_blocklist tracking https://www.github.developerdan.com/hosts/lists/tracking-aggressive-extended.txt

# https://firebog.net - Suspicious Lists
process_blocklist malware  https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt
process_blocklist malware  https://v.firebog.net/hosts/static/w3kbl.txt

# https://firebog.net - Advertising Lists
process_blocklist ads      https://v.firebog.net/hosts/AdguardDNS.txt
process_blocklist ads      https://v.firebog.net/hosts/Admiral.txt
process_blocklist ads      https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt
process_blocklist ads      https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
process_blocklist ads      https://v.firebog.net/hosts/Easylist.txt
process_blocklist ads      https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext
process_blocklist ads      https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts
process_blocklist ads      https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts

# https://firebog.net - Malicious Lists
process_blocklist malware  https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
process_blocklist malware  https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt
process_blocklist malware  https://v.firebog.net/hosts/Prigent-Crypto.txt
process_blocklist malware  https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
process_blocklist malware  https://phishing.army/download/phishing_army_blocklist_extended.txt
process_blocklist malware  https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt
process_blocklist malware  https://v.firebog.net/hosts/Shalla-mal.txt
process_blocklist malware  https://raw.githubusercontent.com/Spam404/lists/master/main-blocked-names.txt
process_blocklist malware  https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts
process_blocklist malware  https://urlhaus.abuse.ch/downloads/hostfile/

# https://firebog.net - Other Lists
process_blocklist crypto   https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser


# Combine blocklists
cat /etc/dnscrypt-proxy/blocked-names/*/* > /etc/dnscrypt-proxy/blocked-names.txt.tmp

# Clean up combined blocklists
sort --unique /etc/dnscrypt-proxy/blocked-names.txt.tmp > /etc/dnscrypt-proxy/blocked-names.txt
rm -v /etc/dnscrypt-proxy/blocked-names.txt.tmp
chown _dnscrypt-proxy:root /etc/dnscrypt-proxy/blocked-names.txt
