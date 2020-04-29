#!/bin/bash

set -ex

# Clone self-hosted if it doesn't exist
if ! [ -d self-hosted ]; then
  git clone "https://github.com/gitpod-io/self-hosted.git"
fi
cd self-hosted || exit
# Necassary Kubernetes stuffs
kubectl create -f utils/helm-2-tiller-sa-crb.yaml || echo 'already configured'
helm repo add charts.gitpod.io "https://charts.gitpod.io"
helm dep update
# Get information
provider="GitHub"
domain="sean.gitpod-self-hosted.com"
hosturl="github.com"
clientId="a0d9f23f71a890a581e8"
clientSecret="8f8168940ea7737a69da9dd732b0c879f612ec50"
settingsUrl="https://github.com/settings/connections/applications/$clientId"
# Create the values.yaml file based on information
cat <<EOF >values.yaml
gitpod:
  hostname: $domain
  components:
    proxy:
      loadBalancerIP: null
  authProviders:
  - id: "Github"
    host: "$hosturl"
    protocol: "https"
    type: "$provider"
    oauth:
      clientId: "$clientId"
      clientSecret: "$clientSecret"
      callBackUrl: "https://$domain/auth/github/callback"
      settingsUrl: "$settingsUrl"
  installPodSecurityPolicies: true

docker-registry:
  enabled: true

gitpod_selfhosted:
  variants:
    customRegistry: false
EOF
echo 'values.yaml' >configuration.txt
helm upgrade --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .
real_url=$(kubectl get svc | grep -E '^proxy' | awk '{print $4}')
sed -i "2s/.*/  hostname: $real_url/" values.yaml
sed -i "14s/.*/      callBackUrl: \"https:\/\/$real_url\/auth\/github\/callback\"/" values.yaml
helm upgrade --install $(for i in $(cat configuration.txt); do echo -e "-f $i"; done) gitpod .
printf "\x1b[1;33mDone! Have fun with self hosted! \x1b[m\n"
