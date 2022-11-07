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

## Publish it
```
rsync -Prv /home/evans/gitlab.com/evanstucker/hugo-site/public/ 192.168.1.114:/srv/docker/ipfs/ipfs_fuse/
ssh 192.168.1.114
sudo docker exec -it ipfs ipfs add -r /ipfs
```
