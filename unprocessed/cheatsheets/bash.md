# Bash

### SSH Jump Server (aka tunnel)

```bash
ssh -q -o StrictHostKeyChecking=no -J ubuntu@bastion.$cluster_domain ubuntu@$node -- free -m
```

### POSTing JSON with curl

```bash
batch_post='{"requests":[{"method":"get","path":"/prices","query":{"from":"SNGLS","to":"USD","autoConversion":true}},{"method":"get","path":"/prices","query":{"from":"eth","to":"USD","autoConversion":true}},{"method":"get","path":"/prices","query":{"from":"BCS","to":"USD","autoConversion":true}}]}'
curl -H "Content-Type: application/json" -d "$batch_post" -s -X POST "https://api.dedevsecops.com/"
```

### Shitty bash port scanner

```bash
host=tired-devops-parity-rpc
port=8545
(echo > "/dev/tcp/${host}/${port}") &> /dev/null && echo "${port} is open"
```

### Kill defunct processes (or rather, kill their parents)

```bash
parents_of_dead_kids=$(ps -ef | grep [d]efunct | awk '{print $3}' | sort | uniq | egrep -v '^1$'); echo "$parents_of_dead_kids" | xargs kill
```

### Using timeout to run an export function

I found a better way to check status of rollouts in Kubernetes, but this code is still interesting. TIL how to export a function and use timeout kind of elegantly.

```bash
#!/bin/bash

export TIMEOUT=120
export POLL_INTERVAL=5

function verify_loop {
  echo "INFO: Checking pod state every ${POLL_INTERVAL} seconds for ${TIMEOUT} seconds."
  while true; do
    if kubectl get pods | sed 1d | grep -q -vE "(Running|Completed)"; then
      echo -n "."
      sleep $POLL_INTERVAL
    else
      echo
      exit 0
    fi
  done
}
export -f verify_loop

timeout $TIMEOUT bash -c verify_loop

if [[ $? -ne 0 ]]; then
  echo
  echo "ERROR: Not all pods are in Running state."
  exit 1
else
  echo
  echo "INFO: Success, all pods are in a good state."
fi

```
