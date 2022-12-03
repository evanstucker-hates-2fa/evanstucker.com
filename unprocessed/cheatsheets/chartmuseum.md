# Chartmuseum

## Export charts
```
mkdir -p ~/chartmuseum/storage
kubectl cp chartmuseum-chartmuseum-86544fcbcf-dfjzw:/storage ~/chartmuseum/storage
```

## Import charts
```
for chart in *.tgz; do
  curl -u "${CHARTMUSEUM_USER}:${CHARTMUSEUM_PASSWORD}" --data-binary "@${chart}" https://chartmuseum.ur-domain.com/api/charts;
done
```
