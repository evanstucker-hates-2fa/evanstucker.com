---
title: "Chartmuseum"
draft: false
---
## Export charts

```bash
mkdir -p ~/chartmuseum/storage
kubectl cp chartmuseum-chartmuseum-86544fcbcf-dfjzw:/storage ~/chartmuseum/storage
```

## Import charts

```bash
for chart in *.tgz; do
  curl -u "${CHARTMUSEUM_USER}:${CHARTMUSEUM_PASSWORD}" --data-binary "@${chart}" https://chartmuseum.ur-domain.com/api/charts;
done
```
