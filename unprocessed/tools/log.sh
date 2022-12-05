#!/bin/bash

# This is intended as a library to add logging capabilities to your Bash
# script. To use it, include it at the top of your Bash script with the source
# command:

# source log.sh

# Once you have sourced it, you can use the "log" function to generate various
# information or error messages. Here are some examples:

# log FATAL 'Cats and dogs living together!'
# log ERROR $'I can\'t do that, Dave.'
# log WARN 'That would be inadvisable.'
# log INFO 'I did that thing what you axed me to do.'
# log DEBUG "log_level = ${log_level}"
# log TRACE "In the stupid for loop that doesn't seem to work."

# The default log level is 300 (which shows messages of WARN or higher
# priority). You can set the log level by setting the log_level variable to
# whatever integer you like. See the case statement below for the various
# levels. A good way to allow this to be set at run time is to use getops with
# an argument like "-v" where "-v" sets log_level to 400.

# Anything logged as FATAL will also cause the program to exit.

function log {
    log_level=${log_level:=300}
    case $1 in
        'FATAL') level=100;;
        'ERROR') level=200;;
        'WARN')  level=300;;
        'INFO')  level=400;;
        'DEBUG') level=500;;
        'TRACE') level=600;;
        *)
            echo "$(date +%FT%T) FATAL Bad argument to the \"log\" function." >&2
            exit 1
            ;;
    esac
    if [[ $level -le $log_level ]]; then
        echo "$(date +%FT%T) $1 $2" >&2
        if [[ $level == 100 ]]; then
            exit 1
        fi
    fi
}
