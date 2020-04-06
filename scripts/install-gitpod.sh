#!/bin/bash

set -ex

cd src || exit
terraform init
did_fail="failed"
# Take varriardic arguments from $1 on, the or statement will be used for error handling incase the install fails
echo 'yes' | terraform apply "${@:1}" || did_fail=""
if [ -z "$did_fail" ]; then
  printf "\x1b[31mSomething went wrong during the installation of Gitpod Self Hosted for AWS. This should not happen. Destroying any dangling infrastructure. Please file an issue at https://github.com/gitpod-io/self-hosted\x1b[m"
  echo 'yes' | terraform destroy
  exit
fi
# Configure local machine for the kubernetes cluseter
aws eks --region "$(cat <(terraform output region))" update-kubeconfig --name "$(cat <(terraform output cluster_name))"
kubectl apply -f <(terraform output config_map_aws_auth)
# Clone self-hosted if it doesn't exist
if ! [ -d self-hosted ]; then
  git clone "https://github.com/gitpod-io/self-hosted.git"
fi
cd self-hosted || exit
# Necassary Kubernetes stuffs
kubectl create -f utils/helm-2-tiller-sa-crb.yaml
helm repo add charts.gitpod.io "https://charts.gitpod.io"
helm dep update
# The point of this script is automation as I couldn't get it done in a provisioner and since we require a static IP its the first argument
cat <<EOF >values.yaml
gitpod:
  hostname: $1
  components:
    proxy:
      loadBalancerIP: null
EOF
# If self-hosted already exists there is a chance that there is extra configuration for self-hosted which the following honors
if [ -f "configuration.txt" ]; then
  helm upgrade --install "$(for i in "$(cat configuration.txt)"; do echo -e "-f $i"; done)" gitpod .
else
  helm install gitpod .
fi
cd .. || exit
rm -rf self-hosted
printf "\x1b[1;33Done! Have fun with self hosted!\x1b[m"
