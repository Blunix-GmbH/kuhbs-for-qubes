# Convert sources.list http:// entries to https:// - can not be cached by caching proxy
sed -i 's@ http://@ https://@g' /etc/apt/sources.list
sed -i 's@ http://@ https://@g' /etc/apt/sources.list.d/*list
