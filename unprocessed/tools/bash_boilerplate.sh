#!/bin/bash

# Bash Best Practices

# Don't use backticks (ie. ``) - they don't nest. Use $() instead. Example: 
# This is deprecated... and it doesn't work.
# ip=`dig +short `hostname` A`
# This works.
# ip=$(dig +short $(hostname) A)

# Scripts should set their own environment.  At a minimum they should set their PATH. 

# Scripts should have reliable exit codes.  Zero should always be success, non-zero should be failure.

# Never put "su" in a script.

# Use single quotes by default. The only time you should enclose something in double-quotes is if there is a variable.

# Indentation should be set to 4 spaces - do not use tabs. An easy way to ensure this is to use this .vimrc: 
# autocmd FileType sh setlocal et sw=4 sts=4
 
PATH='/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin'
required_user=root
required_host=wwwdmav700.athenahealth.com
 
# Try to follow the standard usage formatting found here:
# https://en.wikipedia.org/wiki/Usage_message
function usage {
cat <<EOF
$(basename $0) does cool stuff. It must be run as ${required_user} on ${required_host}.
 
Usage:
 
    $(basename $0) [-h] [-t]
 
    -h  Help
    -t  Test. The script won't do anything; it just shows what it would do.
  
Examples:
  
    Run a test:
    $(basename $0) -t
 
EOF
exit 1
}
 
function err {
    red='\033[0;31m'
    normal='\033[0m'
    printf "${red}ERROR: ${1}${normal}\n" >&2
    exit 1
}
  
while getopts :ij:rRvh option; do
    case $option in
        i) i_func;;
        j) j_arg=$OPTARG;;
        r) rflag=true; small_r=true;;
        R) rflag=true; big_r=true;;
        v) v_func; other_func;;
        h) usage;;
        \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $(($OPTIND - 1))
echo "$@"
 
if [[ $# -eq 0 ]]; then
  usage
fi
 
if [[ "$(whoami)" != "${required_user}" ]]; then
    err "This script must be run as ${required_user}."
elif [[ "$(hostname)" != "${required_host}" ]]; then
    err "This script must be run on ${required_host}."
fi
