#!/bin/bash

set -x

cd src || exit
terraform init
did_fail="failed"
echo 'yes' | terraform apply "$@" || did_fail=""
if [ -z "$did_fail" ]; then
  echo 'yes' | terraform destroy
  exit
fi
aws eks --region "$(cat <(terraform output region))" update-kubeconfig --name "$(cat <(terraform output cluster_name))"
kubectl apply -f <(terraform output config_map_aws_auth)
if ! [ -d self-hosted ]; then
  git clone "https://github.com/gitpod-io/self-hosted.git"
fi
cd self-hosted || exit
kubectl create -f utils/helm-2-tiller-sa-crb.yaml
helm repo add charts.gitpod.io "https://charts.gitpod.io"
helm dep update
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
cat <<EOF >values2.yaml
gitpod:
  hostname: $hosturl
  components:
    proxy:
      loadBalancerIP: null
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
if [ -f "configuration.txt" ]; then
  helm upgrade --install "$(for i in "$(cat configuration.txt)"; do echo -e "-f $i"; done)" gitpod .
else
  helm install gitpod .
fi
cd .. || exit
rm -rf self-hosted
