# Show git log commands for all secrets
```
$ gitleaks_output="$(docker run -v "${PWD}":/path zricethezav/gitleaks:latest detect -s /path -v)"
$ echo $gitleaks_output | jq -r '. | "git log -L \(.StartLine),\(.EndLine):\(.File) \(.Commit)"'
git log -L 24,24:cd/kustomize/applications/orchestrate/api-envelope-store.yaml 8951d23432ebf249fb39d71e2997104d77aca3c7
git log -L 24,24:cd/kustomize/applications/orchestrate/api-contract-registry.yaml c7e96ff0f35132ede479c84dc8fc3863bac4ffd7
```
