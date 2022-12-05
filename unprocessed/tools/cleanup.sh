#!/bin/bash

function usage {
cat <<TAC

$(basename $0) does consistent, repeatable filesystem cleanup. It should be run
by cron on a short interval to catch a file system that's growing before it
triggers an alert.

Usage:

    $(basename $0) [-h] [-t]

    -h  Help
    -t  Test. The script won't do anything; it just shows what it would do.

TAC
exit 1
}

###############################################################################
#
# NOTE TO ANYONE EDITING THIS SCRIPT:
#
# Do not exec any commands other than safer_gzip and safer_rm or you will break
# test mode!
#
###############################################################################

# This does generic tomcat cleanup. It removes all non-open files from the
# tomcat cache, removes logs older than 30 days, and compresses everything
# older than 14 days. It requires the tomcat_log_dir variable.
function cleanup_tomcat {
    if [[ -z $tomcat_log_dir ]]; then
        echo 'ERROR: tomcat_log_dir is not set.' >&2
        exit 1
    else
        find /var/cache/tomcat6/temp -type f -exec safer_rm.sh "${safer_options[@]}" {} ';'
        find "/var/log/tomcat6/${tomcat_log_dir}" -type f -mtime +30 -exec safer_rm.sh "${safer_options[@]}" {} ';'
        find "/var/log/tomcat6/${tomcat_log_dir}" -type f -mtime +14 -exec safer_gzip.sh "${safer_options[@]}" {} ';'
    fi
}

function check_fs_usage {
    # This script shouldn't actually do anything unless a file system's percent
    # usage is over this threshold. This variable should be set to one or two
    # percent less than the alarm threshold (the percent at which our
    # monitoring system sends an alarm.)
    action_threshold=${action_threshold:=88}

    # This starts with the last line which uses process substitution to create
    # a virtual file that I'm redirecting into the while loop. Normally I just
    # pipe the output of a command into a while loop, but when you do that, the
    # while loop becomes a subshell and the variables are local to that
    # subshell.  However, if you redirect a file into the while loop, the
    # variables are available in the local shell... It uses df to print local
    # files systems, then sed to delete the first line (headers) and any
    # percent signs, then awk to print the fifth and sixth fields separated
    # with a tab. The while loop reads those two fields and assigns them to the
    # fs_usage and fs_name variables.  Finally, if the file system usage is
    # greater than the action threshold, the file system name is added to an
    # array.
    while read fs_usage fs_name; do
        if [[ $fs_usage -gt $action_threshold ]]; then
            at_risk_filesystems+=("${fs_name}")
        fi
    done < <(df -Pl | sed '1d;s/%//;' | awk '{printf("%s\t%s\n",$5,$6)}')
}

cleanup_path='/root/bin'

PATH="/bin:/usr/bin:/sbin:/usr/sbin:${cleanup_path}"

# Set default options for the safer_*.sh commands. I'm setting verbose here,
# because I will be sending the output of this script to syslog as well as
# e-mailing it, and I want it to show everything that it does.
safer_options=(-v)

if [[ "$(whoami)" != 'root' ]]; then
    echo 'ERROR: This script must be run as root due to:' >&2
    echo >&2
    echo '* fuser' >&2
    echo '* safer_rm.sh' >&2
    echo '* safer_gzip.sh' >&2
    exit 1
elif [[ ! -f "${cleanup_path}/safer_gzip.sh" ]]; then
    echo "ERROR: Missing file: ${cleanup_path}/safer_gzip.sh" >&2
    exit 1
elif [[ ! -f "${cleanup_path}/safer_rm.sh" ]]; then
    echo "ERROR: Missing file: ${cleanup_path}/safer_rm.sh" >&2
    exit 1
fi

while getopts ht option; do
    case $option in
        h) usage;;
        t) safer_options+=(-t);;
    esac
done

check_fs_usage

app=$(facter -p epocappcode)

for filesystem in "${at_risk_filesystems[@]}"; do
    if [[ -f "${cleanup_path}/cleanup_${app}.sh" ]]; then
        source "${cleanup_path}/cleanup_${app}.sh"
    fi
done
