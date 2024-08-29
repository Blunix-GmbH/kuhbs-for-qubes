# Convert sources.list https:// entries to http:// for apt-cacher-ng
sed -i 's@ https://@ http://@g' /etc/apt/sources.list
sed -i 's@ https://@ http://@g' /etc/apt/sources.list.d/*list
