#!/bin/bash

set -euxo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 'cool-title'"
  exit 1
fi

cd ~/gitlab.com/evanstucker/hugo-site

# Create a title in lowercase with hyphens instead of spaces and no special chars
title="$1"

# Get date
date=$(date -I)

# Create a post, then edit it
hugo new "posts/${date}-${title}.md"

vim "content/posts/${date}-${title}.md"

# Test it
echo 'http://localhost:1313'
hugo server

# Build it
hugo

# Commit it
git commit -am ...
git push

# Copy it to the server
rsync -Prv /home/evans/gitlab.com/evanstucker/hugo-site/public/ 192.168.1.114:/srv/docker/ipfs/ipfs_fuse/

cat <<EOF

# Connect to the IPFS container on the server
ssh 192.168.1.114
sudo docker exec -it ipfs sh

# Add it to IPFS
CID=\$(ipfs add -Q -r /ipfs)

# Check it
echo "https://ipfs.6j0.org/ipfs/\${CID}"

# Update _dnslink.evanstucker.com
echo "dnslink=/ipfs/\${CID}"
EOF
