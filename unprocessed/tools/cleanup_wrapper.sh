#!/bin/bash

if [[ "$(whoami)" != 'root' ]]; then
    echo 'ERROR: This script must be run as root due to:' >&2
    echo >&2
    echo '* cleanup.sh' >&2
    exit 1
fi

# Added -t to force test-only mode for now.
/root/bin/cleanup.sh &> >(logger -s -t $(readlink -f $0))
