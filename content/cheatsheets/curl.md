---
title: "curl"
draft: false
---
## POSTing JSON

```bash
batch_post='{"requests":[{"method":"get","path":"/prices","query":{"from":"SNGLS","to":"USD","autoConversion":true}},{"method":"get","path":"/prices","query":{"from":"eth","to":"USD","autoConversion":true}},{"method":"get","path":"/prices","query":{"from":"BCS","to":"USD","autoConversion":true}}]}'
curl -H "Content-Type: application/json" -d "$batch_post" -s -X POST "https://api.dedevsecops.com/"
```
