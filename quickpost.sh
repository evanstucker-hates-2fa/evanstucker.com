#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo 'ERROR: Requires title as argument.' >&2
  exit 1
fi

date=$(date -I)

title="$1"
if [[ "$title" =~ [^a-z0-9-] ]]; then
  echo 'ERROR: Title must be lowercase alphanumeric or hyphen with no other special characters.' >&2
  exit 1
fi

hugo new "posts/${date}-${title}.md"
xdg-open "content/posts/${date}-${title}.md"

exit

# Test it
echo 'http://localhost:1313'
hugo server

# Build it
hugo

# Authenticate, commit, and push
rad auth
git commit -am ...
rad push

# Copy it to the server
rsync -Prv --del --stats public/ 192.168.1.114:/srv/docker/ipfs/ipfs_fuse/

# Connect to the IPFS container on the server
ssh 192.168.1.114
sudo docker exec -it ipfs sh

# Add it to IPFS
CID=$(ipfs add -Q -r /ipfs)

# Check it
echo "https://ipfs.6j0.org/ipfs/${CID}"

# Update _dnslink.evanstucker.com
echo "dnslink=/ipfs/${CID}"
```
