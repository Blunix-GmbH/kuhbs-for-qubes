# Usage: kuhbs any-undefined-argument
kuhbs_usage() {

    cat << EOF
## Related to a kuhb

# Show the state of each kuh defined in all kuhbs
kuhbs ls

# Show the state of a specific kuh
kuhbs show tool/firefox

# Create a kuhb
kuhbs create tool/firefox

# Remove a kuhb
kuhbs remove tool/firefox

# Backup a kuhb
kuhbs backup tool/firefox

# Backup all defined and created kuhb's
kuhbs backup-all

# Restore the backup of a kuhb
kuhbs restore tool/firefox

# Upgrade the software of each kuh that is used as a template within a kuhb
kuhbs upgrade tool/firefox

# Upgrade all defined and created kuhbs
kuhbs upgrade-all


## Related to a specific kuh

# Open a graphical terminal on a kuh
kuhbs terminal <qube> [user]
kuhbs terminal app-tool-firefox root
kuhbs terminal app-tool-firefox user
kuhbs terminal app-tool-firefox

# xl stop a kuh and dump its memory and disks to dom0:$DUMP_DIR
kuhbs dump app-tool-firefox


## Debugging

# Enable verbose output
kuhbs -v <action> <arg>
kuhbs -v create tool/firefox

# Enable debug mode (implies verbose mode as well)
kuhbs -d <action> <arg>
kuhbs -d create tool/firefox
EOF
}
