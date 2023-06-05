# Show movies with no reviews:
```
cat unprocessed/movies.json | jq '. | map(select(.review == null)) | .[].title'
```
