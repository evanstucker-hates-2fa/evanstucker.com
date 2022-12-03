# Google Cloud

## Delete old snapshots

```bash
gcloud compute snapshots delete $(gcloud compute snapshots list --filter 'creationTimestamp<=2019-03-03' --format json | jq -r '.[].name')
```
