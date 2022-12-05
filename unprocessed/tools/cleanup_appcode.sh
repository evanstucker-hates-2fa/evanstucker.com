#!/bin/bash

# This script is called by cleanup.sh

case $filesystem in
    '/var')
        find /var/log/jetty -type f \( -mtime +14 -o -name '*.request.log*' \) -exec safer_rm.sh "${safer_options[@]}" {} ';'
        find /var/log/jetty -type f -exec safer_gzip.sh "${safer_options[@]}" {} ';'
        ;;
esac
