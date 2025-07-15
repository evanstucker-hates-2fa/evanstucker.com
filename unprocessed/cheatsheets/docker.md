# Docker cheat sheet

## Find a container image SHA without having to download it:

```
docker buildx imagetools inspect python:3.13.2-slim-bookworm --format '{{json .}}' | jq -r '.manifest.digest'
```
