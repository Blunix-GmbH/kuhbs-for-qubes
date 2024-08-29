set -e -x


# Set kuhbs-net-gateway as default update VM
sed -i 's/target=ndp-kuhbs-net-gateway/target=sys-net/g' /etc/qubes/policy.d/90-default.policy

# Set default updatevm
qubes-prefs updatevm sys-net

# Start the update VM
qvm-start --skip-if-running sys-net
