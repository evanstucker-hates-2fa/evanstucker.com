#!/bin/bash

function usage {
cat <<TAC

$(basename $0) checks to see if a file is open before removing it.

Usage:

    $(basename $0) [-t] [-v] file...

    -t  Test: Shows which files it would remove, but doesn't actually do anything.
    -v  Verbose: Equivalent to "rm -v".

TAC
exit 1
}

PATH='/bin:/usr/bin:/sbin'

while getopts tv option; do
    case $option in
        t) test=1;;
        v) rm_options+=(-v);;
    esac
done
shift $(($OPTIND - 1))

if [[ $# == 0 ]]; then
    usage
elif [[ "$(whoami)" != 'root' ]]; then
    echo 'ERROR: This script must be run as root, because it uses /sbin/fuser.' >&2
    exit 1
fi

for file in "$@"; do

    # I put these two commands on the same line to ensure that fuser_exit always
    # gets set immediately after fuser runs. Don't mess with this line. 
    fuser -s "${file}"; fuser_exit=$?;

    if [[ $fuser_exit == 1 ]]; then
        if [[ $test == 1 ]]; then
            echo "INFO: #rm ${rm_options[@]} ${file}"
        else
            rm "${rm_options[@]}" "${file}"
        fi
    elif [[ $fuser_exit == 0 ]]; then
        echo "WARNING: Skipping ${file}, file is open."
    else
        echo "WARNING: Skipping ${file}, fuser exit code was ${fuser_exit}."
    fi

done
