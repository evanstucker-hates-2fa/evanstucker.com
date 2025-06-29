# Hugo cheatsheet

```
# Get date
date=$(date -I)

# Create a title in lowercase with hyphens instead of spaces and no special chars
title="cool-title"

# Create a post
hugo new "posts/${date}-${title}.md"

# Edit it
vim "content/posts/${date}-${title}.md"

# Test it
echo 'http://localhost:1313'
hugo server

# Update theme submodules
git submodule update --recursive --remote

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

## Other notes

I increased the width of the Papermod theme by adding `themes/PaperMod/assets/css/extended/theme-vars.css`, with this content:

```
:root {
    --main-width: 1000px;
}
```

per these instructions: https://github.com/adityatelange/hugo-PaperMod/discussions/442
