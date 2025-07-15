______________________________________________________________________

## title: "Amazon Web Services (AWS)" draft: false

## Miscellaneous

```bash
export AWS_PROFILE=your_AWS_profile
export AWS_DEFAULT_REGION=us-east-1
export account_id=$(aws sts get-caller-identity --output json | jq -r .Account)

aws ec2 describe-snapshots --owner-ids $account_id | jq -r '.Snapshots[] | .VolumeId,.SnapshotId'
aws ec2 describe-volumes | jq -r '.Volumes[] | .VolumeId'
aws ec2 describe-volumes | jq '.Volumes[] | select(.Tags[].Value == "*mongo*")'
aws ec2 describe-snapshots --filters 'Name=status,Values=pending'
aws ec2 describe-volumes --filters 'Name=tag:Name,Values=*mongo*' --query 'Volumes[*].VolumeId'

aws s3 cp "s3://${bucket_name}/${NAME}/pki/issued/ca/" . --recursive --exclude '*' --include '*.crt'

for ssm_param in $(aws ssm describe-parameters | jq -r .Parameters[].Name); do
  aws ssm get-parameters --name "$ssm_param" --with-decryption | jq '.Parameters[] | { "Name": .Name, "Value": .Value }'
done
```

## Get all AWS Secrets Manager secrets for a particular environment

```bash
aws ssm get-parameters-by-path --path "/Services/pizza" --recursive --with-decryption > pizza_secrets.json
```

## Find unencrypted Kubernetes PVC volumes

```bash
aws ec2 describe-volumes --region us-east-2 | jq '.Volumes[] | select(.Encrypted==false) | .Tags[]? | select(.Key=="kubernetes.io/created-for/pvc/name") | .Value'
```

## List all AWS SSO Roles

```bash
aws iam list-roles | jq -r '.Roles[] | select(.RoleName|test("AWSReservedSSO")) | .Arn'
```

## Delete snapshots older than 3 months

```bash
export account_id=$(aws sts get-caller-identity --output json | jq -r .Account)
export AWS_PROFILE=your_profile_name
export AWS_DEFAULT_REGION=us-east-1
export temp_dir=/tmp/delete_snapshots

#aws ec2 describe-snapshots --owner-ids $account_id | jq -r '.Snapshots[] | .VolumeId,.SnapshotId'
#aws ec2 describe-volumes | jq -r '.Volumes[] | .VolumeId'
#aws ec2 describe-volumes | jq '.Volumes[] | select(.Tags[].Value == "*mongo*")'
#aws ec2 describe-snapshots --filters 'Name=status,Values=pending'
#aws ec2 describe-volumes --filters 'Name=tag:Name,Values=*mongo*' --query 'Volumes[*].VolumeId'

for region in $(aws ec2 describe-regions | jq -r .Regions[].RegionName); do
  export AWS_REGION="${region}"
  aws ec2 describe-volumes > "${temp_dir}/volumes-${region}.json"
  cat "${temp_dir}/volumes-${region}.json" | jq -r '.Volumes[] | .VolumeId' > "${temp_dir}/volume-ids-${region}.txt"
  aws ec2 describe-snapshots --owner-ids $account_id > "${temp_dir}/snapshots-${region}.json"
  cat "${temp_dir}/snapshots-${region}.json" | jq -cr '.Snapshots[] | [ .VolumeId, .StartTime, .SnapshotId ]' > "${temp_dir}/snapshots-${region}.txt"
  while read snapshot; do
    volume_id=$(echo $snapshot | cut -d\" -f 2)
    start_time=$(date +%s -d $(echo $snapshot | cut -d\" -f 4))
    snapshot_id=$(echo $snapshot | cut -d\" -f 6)
    if ! (grep -q "$volume_id" "${temp_dir}/volume-ids-${region}.txt"); then
      echo "aws ec2 delete-snapshot --snapshot-id $snapshot_id # original volume no longer exists"
    elif [[ $start_time -lt $(date +%s -d '3 months ago') ]]; then
      echo "aws ec2 delete-snapshot --snapshot-id $snapshot_id # snapshot is older than 3 months"
    fi
  done < "${temp_dir}/snapshots-${region}.txt" | tee "${temp_dir}/delete-snapshots-${region}.sh"
done
```

```bash
# Less stupid way to generage kubeconfigs for AWS EKS clusters
aws --profile $AWS_PROFILE eks update-kubeconfig --name $cluster_name --region $AWS_REGION --kubeconfig ~/.kube/$cluster_name --user-alias "${cluster_name}_${AWS_REGION}_${AWS_PROFILE}" --alias "${cluster_name}_${AWS_REGION}_${AWS_PROFILE}"

```

## saml2aws

Don't bother using `saml2aws configure` - use this script instead: https://github.com/devopscoop/scripts/blob/add-saml2aws-script/configure_saml2aws.sh

```
# Do this once every 12 hours. Doesn't matter which role you use, they all share the same cache.
saml2aws login

# If you have some application that requires `AWS_*` env vars for some reason, you can do this:
eval $(saml2aws script -p $AWS_PROFILE)
```

## Running a command on all AWS profiles in all regions

```
for AWS_PROFILE in $(aws configure list-profiles); do
  export AWS_PROFILE
  for AWS_REGION in $(aws --region us-east-1 ec2 describe-regions | jq -r .Regions[].RegionName); do
    export AWS_REGION
    echo "Put your command here"
  done
done
```
