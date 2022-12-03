#!/bin/bash
for url in $(cat ipfs.evanstucker.com/bookmarks.json | jq -r .[].url); do
  response=$(curl -D - -L -s $url)
  title=$(echo "$response" | tr -d '\n' | grep -io '<title>.*</title>' | sed 's/<[\/]*title>//g' | recode ascii..html)
  location=$(echo "$response" | grep -o '^Location: .*$' | sed 's/Location: //')
  if [[ $location != "" ]]; then
    echo "INFO: Found 302 at \"$url\"."
  else
    location="$url"
  fi
  echo "{\"url\":\"$location\",\"title\":\"$title\"},"
done
