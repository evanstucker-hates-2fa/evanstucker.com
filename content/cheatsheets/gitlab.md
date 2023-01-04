---
title: "GitLab"
draft: false
---
## Prerequisites

1. Log into gitlab.com.
1. Create a personal access token with "api" scope.
1. Create an env var for the token:
   ```bash
   export token=REDACTED
   ```

## List all groups:

```bash
curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/groups?owned=true | jq .
```

## List all members of a group:

```bash
curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/groups/4934010/members
```

## List all projects in a group:

```bash
curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/groups/4934010/projects | jq .
```

## List all project deploy keys for a specific group:

```bash
for p in $(curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/groups/4934010/projects | jq .[].id); do
  echo "===== $p"
  curl -H "Private-Token: $token" -s "https://gitlab.com/api/v4/projects/${p}/deploy_keys" | jq .
done
```

## Delete deploy keys for a specific group:

```bash
for p in $(curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/groups/4934010/projects | jq .[].id); do
  echo "===== $p"
  for k in $(curl -H "Private-Token: $token" -s "https://gitlab.com/api/v4/projects/${p}/deploy_keys" | jq .[].id); do
    curl -H "Private-Token: $token" -s -X DELETE "https://gitlab.com/api/v4/projects/${p}/deploy_keys/${k}"
  done
done
```

## List all runners:

```bash
curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/runners | jq .
```

## Delete offline runners:

```bash
for r in $(curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/runners?status=offline | jq .[].id); do
  curl -H "Private-Token: $token" -s -X DELETE "https://gitlab.com/api/v4/runners/${r}"
done
```

## List all runners for all projects in a specific group:

```bash
for p in $(curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/groups/4934010/projects | jq .[].id); do
  echo "===== $p"
  curl -H "Private-Token: $token" -s "https://gitlab.com/api/v4/projects/${p}/runners" | jq .
done
```

## BROKEN: Disable all shared runners:

```bash
for p in $(curl -H "Private-Token: $token" -s https://gitlab.com/api/v4/groups/4934010/projects | jq .[].id); do
 echo "===== $p"
 for s in $(curl -H "Private-Token: $token" -s "https://gitlab.com/api/v4/projects/${p}/runners" | jq '.[] | select(.is_shared==true) | .id'); do
   curl -H "Private-Token: $token" -s -X POST "https://gitlab.com/api/v4/projects/${p}/runners/${s}" --form "active=false"
 done
done
```
