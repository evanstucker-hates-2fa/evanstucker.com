# Kubernetes (K8s)

## Overview

Official cheatsheet here: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

I often have to manage multiple clusters, so you'll see a pattern in here where I do for loops over a $clusters variable. That variable contains a space-separated list of cluster names, like this:

    export clusters='cluster1.com cluster2.com cluster3.com'

## Tools

* https://github.com/garethr/kubeval
* https://helm.sh/
* https://kubernetes.io/docs/setup/independent/install-kubeadm/

## Useful Commands

### Show broken pods

This is different than status.phase=Running, because even CrashLoopBackOff pods are in status.phase=Running. This is just a quick view into all things that are broken.

    kubectl get pods --all-namespaces --no-headers | grep -vE '(Running|Completed)' | awk '{print $1}'

### Get all nodes with label zone=db

    kubectl get nodes -l zone=db -o json | jq -r '.items[].metadata.name'

### Port forwarding from my workstation directly to a Kubernetes pod!

Use local_port:remote_port syntax if you already have something running on 27017.

    kubectl port-forward pod/mongodb-0 27017

### Show nodes and pods that are weird/wrong/broken

    for cluster in $clusters; do
      kubectl config use-context $cluster
      kubectl get nodes --no-headers | grep -v ' Ready '
      kubectl get pods --all-namespaces --no-headers  | grep -vE '(Running|Completed)'
    done

### Which pods were evicted from which nodes and why

    for cluster in $clusters; do
      kubectl config use-context $cluster
      for pod in $(kubectl get pods --all-namespaces | grep Evicted | awk '{ print $1 }'); do
        kubectl describe pods $pod | grep -E '^(Name|Node|Message):'
      done
    done

### Delete all Evicted and CrashLoopBackOff pods

    for cluster in $clusters; do
      kubectl config use-context $cluster
      for pod in $(kubectl get pods --all-namespaces | grep -E '(Evicted|CrashLoopBackOff)' | awk '{ print $1 }'); do
        kubectl delete pod $pod
      done
    done

### Show logs for specific container (like initContainer) in a pod

    kubectl logs mydumbapp-0 -c mypeskyinitcontainer

### Check dmesg on all nodes

    for cluster in $clusters; do
      kubectl config use-context $cluster
      for node in $(kubectl get nodes -o json | jq -r '.items[].metadata.name'); do
        ssh -J ubuntu@bastion.$env.evanstucker.com -q -o StrictHostKeyChecking=no ubuntu@$node -- dmesg | grep unregister_netdevice
      done
    done

### Patch memory requests and limits for a deploy

    kubectl patch deploy elasticsearch-master -p '{"spec":{"template":{"spec":{"containers":[{"name":"elasticsearch","resources":{"limits":{"memory":"1024Mi"},"requests":{"memory":"512Mi"}}}]}}}}'

### Why did my pods die?

    for pod in $(kubectl get pods --all-namespaces --no-headers | awk '{print $1}'); do
      echo "===== $pod"
      kubectl get pod $pod -o go-template='{{range.status.containerStatuses}}{{"LastState: "}}{{.lastState}}{{end}}{{"\n"}}' | grep -oiE 'reason:[a-z0-9]+'
    done

### Show node resource requests and limits

The Kubernetes Dashboard would probably be easier to deal with...

    for node in $(kubectl get nodes --no-headers | awk '{print $1}'); do
      echo "===== $node"
      kubectl describe node $node | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve --
      echo
    done

### Find OOMKilled (out of memory) things

One-liner:
```
kubectl get pods -A -o json | jq -r '.items[] | select(.status.containerStatuses[].lastState.terminated.reason == "OOMKilled") | "\(.metadata.namespace)/\(.metadata.name)"'
```
Some weird old way where I was logging into nodes to check:
```
for cluster in $clusters; do
  kubectl config use-context $cluster
  for node in $(kubectl get nodes -o json | jq -r .items[].metadata.name); do
    echo "===== $cluster $node"
    ssh -q -o StrictHostKeyChecking=no -J "ubuntu@bastion.${cluster}" "ubuntu@${node}" -- journalctl -p 3 | grep -i mem
  done
done
```

### Miscellaneous

join <(kubectl get nodes -L kops.k8s.io/instancegroup -L failure-domain.beta.kubernetes.io/zone) <(kubectl top nodes) | column -t

Use 'kubectl replace' instead of delete and apply.

### Adding IAM User mappings to an EKS cluster

This should probably be avoided. You should probably use `eksctl create iamidentitymapping` to add roles to the cluster. But if, for some reason, you need to add user mappings directly:

```bash
kubectl edit cm -n kube-system aws-auth
```
and add the user under `mapUsers: |`:
```yaml
 - userarn: arn:aws:iam::999999999999:user/evans.tucker
   username: admin
   groups:
     - system:masters
```

### Creating a debugging pod that automatically deletes itself when you're done

```bash
kubectl run evanstest --rm -it --image alpine -- /bin/sh
```

### Decrypt and show all secrets for a particular release

```bash
release=postgresql
for secret in $(kubectl get secrets -l release=${release} -o json | jq -r '.items[].data | to_entries[] | "\(.key):\(.value)"'); do
  echo "$(echo $secret | cut -d: -f1): $(echo $secret | cut -d: -f2- | base64 -d)"
done
```

### If a PV get stuck in Terminating status

```bash
for pv in $(kubectl get pv | sed 1d | awk '{ print $1 }'); do
  kubectl patch pv $pv -p '{"metadata":{"finalizers":null}}'
done
```

### Get public address for all EKS nodes

```
kubectl get nodes -o json | jq -r '.items[].status.addresses[] | select(.type=="ExternalDNS") | .address'
```

### Get public DNS for an EKS node from an internal IP address
```
node_ip=192.168.55.173
kubectl get nodes -o json | jq -r ".items[].status | select(.addresses[].address==\"${node_ip}\") | .addresses[] | select(.type==\"ExternalDNS\") | .address"
ec2-15-189-86-169.eu-west-3.compute.amazonaws.com
```

### Add kubeconfig for all clusters in all regions in all AWS accounts to your ~/.kube/config file
```
while read profile; do
  echo "# Profile: ${profile}"
  export AWS_DEFAULT_REGION='us-east-1'
  export AWS_PROFILE="${profile}"
  for region in $(aws ec2 describe-regions | jq -r .Regions[].RegionName); do
    export AWS_REGION="${region}"
    for cluster in $(aws eks list-clusters --region $AWS_REGION | jq -r .clusters[]); do
      name="$(aws eks describe-cluster --region $AWS_REGION --name $cluster | jq -r '.cluster.name')"
      version="$(aws eks describe-cluster --region $AWS_REGION --name $cluster | jq -r '.cluster.version')"
      if [[ -n "$name" ]]; then
        echo "${name} ${AWS_REGION} ${version}"
      fi
    done
  done
done < <(sed -nE "s/^\[profile ['\"]*([^'\"]+)['\"]*\]/\1/p" "${HOME}/.aws/config")
#done < <(grep -o '^\w*\[.*\]' .aws/credentials | sed -E 's/(\[|\])//g')
```

### Add kubeconfig for all clusters in all subscriptions in your Azure account to your ~/.kube/config file
```
az login
for subscription in $(az account list | jq -r '.[].name'); do
  az account set --subscription "${subscription}"
  for cluster in $(az aks list | jq -r '.[] | "\(.name),\(.resourceGroup)"'); do
    name="$(echo "${cluster}" | cut -d, -f1)"
    resource_group="$(echo "${cluster}" | cut -d, -f2)"
    az aks get-credentials --name "${name}" --overwrite-existing --resource-group "${resource_group}"
  done
done
```

### Show all versions of a Helm chart
```
$ helm search repo fluxcd/flux --versions
NAME       	CHART VERSION	APP VERSION	DESCRIPTION
fluxcd/flux	1.11.2       	1.24.1     	Flux is a tool that automatically ensures that ...
fluxcd/flux	1.11.1       	1.24.1     	Flux is a tool that automatically ensures that ...
fluxcd/flux	1.11.0       	1.24.0     	Flux is a tool that automatically ensures that ...
fluxcd/flux	1.10.2       	1.23.2     	Flux is a tool that automatically ensures that ...
...
```

### Monkeypatch all ingresses
```
for ing in $(kubectl get ing -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{"\n"}{end}' 2>/dev/null); do
  ing_namespace=$(echo "$ing" | cut -d'/' -f 1)
  ing_name=$(echo "$ing" | cut -d'/' -f 2)
  kubectl patch ing -n "$ing_namespace" "$ing_name" -p '{"metadata":{"annotations":{"ingressClassName":"temp"}}}'
done
```

### Find unencrypted storageclasses
```
for c in cluster1 cluster2; do echo "# $c"; kubectl config use-context $c; kubectl get sc -o json | jq -r '.items[].parameters | .encrypted // false'; done
```

### Do a rolling restart of all pods in a deployment
```
kubectl rollout restart deployment/abc
```

### Copy a secret from one namespace to another
```
kubectl get secret -n origin-ns my-secret-name -ojson | jq 'del(.metadata.namespace,.metadata.resourceVersion,.metadata.uid) | .metadata.creationTimestamp=null' | kubectl apply -n destination-ns -f -
```

### Watch current events in the cluster
```
k get events --sort-by='.lastTimestamp' -A -w
```

### Listing all Flux v2 resources
```
flux get all -A
```
or, even more comprehensively (Thanks, Iris!): 
```
for i in $(kubectl get crd | awk '$0 ~ /toolkit.fluxcd.io/ { print $1 }'); do
  echo "$i" | sed -e "s/\(^.*$\)/$(tput setaf 1)\1:$(tput sgr 0)/"
  kubectl get $i -A
  echo
done | sed -e "s/\(^.*NAME.*$\)/$(tput setaf 2)\1$(tput sgr 0)/"
```

### Run a command in all clusters or all contexts
```
for c in $(kubectl config get-contexts -o name); do
  kubectl config use-context $c
  k get ns
done
```
