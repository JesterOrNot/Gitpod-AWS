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
cat <<EOF >values.yaml
gitpod:
  hostname: $(kubectl get svc --namespace default proxy --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
  components:
    proxy:
      loadBalancerIP: null
EOF
if [ -f "configuration.txt" ]; then
  helm upgrade --install "$(for i in "$(cat configuration.txt)"; do echo -e "-f $i"; done)" gitpod .
else
  helm install gitpod .
fi
cd .. || exit
rm -rf self-hosted
