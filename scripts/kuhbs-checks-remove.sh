#!/bin/bash
#
# Remove checks kuhb's

set -e


for check_run_vm_type in deb-12 firefox sys-net-nic torbrowser; do
    kuhbs remove "checks/$check_run_vm_type"
done
