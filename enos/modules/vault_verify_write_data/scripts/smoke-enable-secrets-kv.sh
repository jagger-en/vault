#!/usr/bin/env bash

set -e

function retry {
  local retries=$1
  shift
  local count=0

  until "$@"; do
    exit=$?
    wait=$((2 ** count))
    count=$((count + 1))
    if [ "$count" -lt "$retries" ]; then
      sleep "$wait"
    else
      return "$exit"
    fi
  done

  return 0
}

function fail {
	echo "$1" 1>&2
	exit 1
}

binpath=${vault_install_dir}/vault

test -x "$binpath" || fail "unable to locate vault binary at $binpath"

retry 5 "$binpath" status > /dev/null 2>&1

# Create user policy
$binpath policy write reguser -<<EOF
path "*" {
  capabilities = ["read", "list"]
}
EOF

# Enable the userpass auth method
$binpath auth enable userpass > /dev/null 2>&1

# Create new user and attach superuser policy
$binpath write auth/userpass/users/testuser password="passuser1" policies="reguser"

$binpath secrets enable -path="secret" kv
