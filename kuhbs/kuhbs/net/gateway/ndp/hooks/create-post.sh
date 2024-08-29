set -e -x


# Set kuhbs-net-gateway as default update VM
sed -i 's/target=sys-net/target=ndp-kuhbs-net-gateway/g' /etc/qubes/policy.d/90-default.policy

# Set default updatevm
qubes-prefs updatevm ndp-kuhbs-net-gateway

# Start the update VM
qvm-start ndp-kuhbs-net-gateway
