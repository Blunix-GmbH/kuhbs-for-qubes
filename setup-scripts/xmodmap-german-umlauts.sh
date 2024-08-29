# Map let alt key as switch for german umlauts


cat << 'EOF' > /home/user/.Xmodmap
keycode 108 = Mode_switch
keysym e = e E EuroSign
keysym a = a A adiaeresis Adiaeresis
keysym o = o O odiaeresis Odiaeresis
keysym u = u U udiaeresis Udiaeresis
keysym s = s S ssharp
EOF

chmod 640 /home/user/.Xmodmap
