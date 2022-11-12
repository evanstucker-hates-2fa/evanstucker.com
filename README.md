# Hugo cheatsheet

## Creating a new post
Replace `title` with you lowercase title with hyphens.
```
hugo new posts/$(date -I)-title.md
```

## Check it locally
```
sudo docker run --rm -it \
  -v $(pwd):/src \
  -p 1313:1313 \
  klakegg/hugo:latest \
  server
```

## Build it
```
sudo docker run --rm -it \
  -v $(pwd):/src \
  klakegg/hugo:latest
```

## Copy it to the server
```
rsync -Prv /home/evans/gitlab.com/evanstucker/hugo-site/public/ 192.168.1.114:/srv/docker/ipfs/ipfs_fuse/
```

## Connect to the IPFS container on the server
```
ssh 192.168.1.114
sudo docker exec -it ipfs sh
```

## Add and publish it

```
CID=$(ipfs add -Q -r /ipfs)

# Check it
echo "https://ipfs.evanstucker.com/ipfs/${CID}"

# Publish it
# https://docs.ipfs.tech/how-to/publish-ipns/#publishing-ipns-names-with-kubo
IPNS=$(ipfs name publish -Q "/ipfs/${CID}")

# Check it again
echo "https://ipfs.io/ipns/${IPNS}"
```

## Check
