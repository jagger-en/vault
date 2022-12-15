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
testkey=${test_key}
testvalue=${test_value}

test -x "$binpath" || fail "unable to locate vault binary at $binpath"

retry 5 "$binpath" status > /dev/null 2>&1

# Create user policy
$binpath policy write reguser -<<EOF
path "*" {
  capabilities = ["read", "list"]
}
EOF

# Enable the userpass auth method
$binpath auth enable userpass

# Create new user and attach superuser policy
$binpath write auth/userpass/users/user1 password="passuser1" policies="reguser"

retry 5 $binpath kv put secret/test $testkey=$testvalue
