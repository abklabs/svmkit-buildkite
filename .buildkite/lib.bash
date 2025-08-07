#!/usr/bin/env bash

# shellcheck disable=SC1091 # this will be in our PATH at runtime
source opsh
source "$(realpath "$(dirname "${BASH_SOURCE[0]}")")/git.opsh"

lib::import ssh

ssh::begin

# Configure SSH to ignore host key checking
ssh::config <<EOF
Host *
     UserKnownHostsFile /dev/null
     StrictHostKeyChecking no
EOF
