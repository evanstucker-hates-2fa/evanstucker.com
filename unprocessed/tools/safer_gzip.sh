#!/bin/bash

function usage {
cat <<TAC

$(basename $0) checks to see if a file is open before compressing it.

Usage:

    $(basename $0) [-t] [-v] file...

    -t  Test: Shows which files it would compress, but doesn't actually do anything.
    -v  Verbose: Equivalent to "gzip -v".

TAC
exit 1
}

PATH='/bin:/usr/bin:/sbin'
gzip_options=(-q)

while getopts tv option; do
    case $option in
        t) test=1;;
        v) gzip_options+=(-v);;
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
        if [[ $(grep -o compressed <(file "${file}")) == 'compressed' ]]; then
            echo "WARNING: Skipping ${file}, because it's already compressed."
        else
            if [[ $test == 1 ]]; then
                echo "INFO: #gzip ${gzip_options[@]} ${file}"
            else
                gzip "${gzip_options[@]}" "${file}"
            fi
        fi
    elif [[ $fuser_exit == 0 ]]; then
        echo "WARNING: Skipping ${file}, file is open."
    else
        echo "WARNING: Skipping ${file}, fuser exit code was ${fuser_exit}."
    fi

done
