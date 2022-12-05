#!/bin/bash
subnet=$1 # Ex. 172.24.23.64/26
echo "Subnet: $subnet"
network_address=$(ipcalc -n $subnet | cut -d= -f 2)
echo "Network address: $network_address"
broadcast_address=$(ipcalc -b $subnet | cut -d= -f 2)
echo "Broadcast address: $broadcast_address"
ftona=$(echo $network_address | cut -d. -f 1-3) # First three octets of network address
echo "First three octets of network address: $ftona"
ftoba=$(echo $broadcast_address | cut -d. -f 1-3) # First three octets of broadcast address
echo "First three octets of broadcast address: $ftoba"
fofua=$(( $(echo $network_address | cut -d. -f 4) + 1 )) # Fourth octet of first usable address
echo "Fourth octet of first usable address: $fofua"
folua=$(( $(echo $broadcast_address | cut -d. -f 4) - 1 )) # Fourth octet of last usable address
echo "Fourth octet of last usable address: $folua"
first_usable_address="${ftona}.${fofua}"
echo "First usable address: $first_usable_address"
last_usable_address="${ftoba}.${folua}"
echo "Last usable address: $last_usable_address"
