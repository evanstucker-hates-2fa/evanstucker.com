#!/bin/bash

# Takes an IP address and an SSH host specification string as input, and
# returns 0 if the IP is within one of the subnets for that host specification.
# All bastion servers need to be added to the first case statement so you don't
# enter an endless ProxyCommand loop.

ip=$1
input_spec=$2
case $ip in
  10.12.37.64) actual_spec='bastion-west';;
  10.12.6.11) actual_spec='bastion-east';;
esac
if [[ -z "$actual_spec" ]]; then
    network=$(ipcalc -n "${ip}/19" 2>&1 | cut -d= -f2)
    case $network in
      10.28.0.0|10.28.6.0|10.28.12.0) actual_spec='prod-east';;
      10.18.32.0|10.18.9.0|10.18.16.0) actual_spec='prod-west';;
      10.19.0.0) actual_spec='dev-east';;
      10.19.32.0) actual_spec='dev-west';;
    esac
fi
if [[ "${input_spec}" == "${actual_spec}" ]]; then
  exit 0
else
  exit 1
fi
