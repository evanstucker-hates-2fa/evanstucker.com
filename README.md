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
