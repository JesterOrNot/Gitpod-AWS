#!/bin/bash

set -ex

cd src || exit
terraform init
did_fail="failed"
# Take varriardic arguments from $1 on, the or statement will be used for error handling incase the install fails
echo 'yes' | terraform apply "$@" || did_fail=""
if [ -z "$did_fail" ]; then
  printf "\x1b[31mSomething went wrong during the installation of Gitpod Self Hosted for AWS. This should not happen. Destroying any dangling infrastructure. Please file an issue at https://github.com/gitpod-io/self-hosted\x1b[m\n"
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
# Get information
read -p "Are you using GitHub or Gitlab (GH/GL): " provider
read -p "What is your domain URL (e.g. example.com): " domain
read -p "What is your Git host URL: (e.g. github.com)" hosturl
read -p "What is your oauth client id: " clientId
read -p "What is the client secret: " clientSecret
if [ "$provider" = "GH" ]; then
  providerType="GitHub"
else
  providerType="GitLab"
fi
if [ "$provider" = "GH" ]; then
  settingsUrl="https://github.com/settings/connections/applications/$clientId"
else
  settingsUrl="gitlab.com/profile/applications"
fi
# Create the values.yaml file based on information
cat <<EOF >values.yaml
gitpod:
  hostname: $domain
  components:
    proxy:
      loadBalancerIP: "$domain"
  authProviders:
  - id: "My ID"
    host: "$hosturl"
    protocol: "https"
    type: "$providerType"
    oauth:
      clientId: "$clientId"
      clientSecret: "$clientSecret"
      callBackUrl: "https://$domain/auth/github/callback"
      settingsUrl: "$settingsUrl"
  installPodSecurityPolicies: true
EOF
# If self-hosted already exists there is a chance that there is extra configuration for self-hosted which the following honors
if [ -f "configuration.txt" ]; then
  helm upgrade --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .
else
  helm install gitpod .
fi
# cleanup
cd .. || exit
rm -rf self-hosted
printf "\x1b[1;33mDone! Have fun with self hosted! \x1b[m\n"
