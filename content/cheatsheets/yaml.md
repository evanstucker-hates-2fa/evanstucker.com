---
title: "YAML"
draft: false
---
```
# Add or copy a key value pair to file1.yaml
yq -i ".newkey += \"example value\"" file1

# Double quote all values
yq -i '..style="double"' file1

# Sort keys
yq -i 'sort_keys(..)' file1

# Find duplicates
yq -P -oprops 'sort_keys(..)' file1 file2 | sort | uniq -d

# Deduplicate
# Reads file1 and file2, and removes duplicate yaml lines from file2.
# Usage: deduplicate file1 file2
function deduplicate {
  while read -r line; do
    key=$(echo "$line" | cut -d= -f1)
    if [[ -z $key ]]; then
      continue
    fi
    yq -i "del(.${key})" "$2"
  done < <(yq -oprops 'sort_keys(..)' "$1" "$2" | sort | uniq -d)
}

# Remove empty maps and arrays
# https://stackoverflow.com/questions/68264327/how-to-remove-an-empty-map-from-yaml-using-yq
# Usage: delete_empty file1
function delete_empty {
  while [[ "$(yq 'map(.. | select(length == 0)) | any' "$1")" = "true" ]]; do
   yq -i 'del(.. | select(length == 0))' "$1"
  done
}

# Merge file1 and file2 (values from file2 will take precedence if the keys already exist in file1)
merged_yaml=$(mktemp)
for f in file1 file2; do
  yq -i ". *= load(\"$f\")" "$merged_yaml"
done
```
