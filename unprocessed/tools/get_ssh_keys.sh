#!/bin/bash

set -euo pipefail

cat <<TAC

This will wipe out your existing ~/.ssh/known_hosts and replace it with one
that's up to date as of today. This is not terribly secure, because if a
server has been hijacked, this will wipe out it's old key and you won't get
prompted about the server having a different key. However, this is very
convenient, because you won't have to type yes a thousand times if you issue
an ssh command to all servers. Ideally, we need to implement
https://tools.ietf.org/html/rfc4255 to put our SSH keys in DNS.

Anywho, do you want to go ahead and wipe out your existing known_hosts file? If
so, type "delete it" and press Enter.

TAC
read response

if [[ $response == 'delete it' ]]; then
    echo "Generating a new known_hosts file..."
    ssh-keyscan -f <(for fqdn in $(lssrv.sh all); do
        ip=$(dig +short $fqdn A)
        hostname=$(echo $fqdn | cut -d '.' -f 1)
        if [[ $ip != '' ]]; then
            echo "${fqdn},${hostname},${ip}"
        fi
        ip=''
    done) > ~/.ssh/known_hosts
fi
