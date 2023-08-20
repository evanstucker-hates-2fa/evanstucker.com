---
title: "YAML"
draft: false
---
## Find duplicates
```
yq -P -oprops 'sort_keys(..)' file1.yaml file2.yaml | sort | uniq -d
```
