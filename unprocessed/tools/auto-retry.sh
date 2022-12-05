#!/bin/bash

function usage {
cat <<EOF
$(basename ${BASH_SOURCE[0]}) automatically retries a command until it succeeds.
 
Usage:
 
    $(basename ${BASH_SOURCE[0]}) [-h] [-t] command
 
    -h  Help

    -i  Interval in seconds. This is how many seconds it waits after each command failure before retrying.
        Default: 3

    -n  Number of tries. This is how many attempts we try the command before giving up.
        Default: 600 (600 attempts with a 3 second interval is 30 minutes of retrying.)

Examples:
  
    $(basename ${BASH_SOURCE[0]}) -i 30 -n 20 ssh pdxnpsensu02 $'uptime | grep -q \'up [0-9] mins\''

    For complex commands wrap them in bash like this:

    $(basename ${BASH_SOURCE[0]}) bash -c 'curl http://google.com | grep -q moved'
 
EOF
exit 1
}
 
while getopts :i:n:h option; do
    case $option in
        h) usage;;
        i) interval=$OPTARG;;
        n) num_tries=$OPTARG;;
        \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $(($OPTIND - 1))

if [[ $# -eq 0 ]]; then
  usage
fi

# Set default values
interval=${interval:-3}
num_tries=${num_tries:-600}

if [[ $num_tries -eq 1 ]]; then
  echo "ERROR: If you're setting the number of tries to 1, then you shouldn't be using this script." >&2
  exit 1
fi

count=1
while [[ $count -le $num_tries ]]; do
  "$@" && break
  (( count++ ));
  sleep $interval
done
