#!/bin/bash

set -x

cd src || exit

terraform init
echo 'yes' | terraform apply || echo 'yes' | terraform destroy

aws eks --region us-east-2 update-kubeconfig --name gitpod-cluster

terraform output config_map_aws_auth > config_map_aws_auth.yaml

kubectl apply -f config_map_aws_auth.yaml

if ! [ -d self-hosted ]
then
    git clone "git://github.com/gitpod-io/self-hosted"
fi

cd self-hosted

helm repo add bitnami "https://charts.bitnami.com/bitnami"
helm repo add charts.gitpod.io "https://charts.gitpod.io"
helm dep update
helm repo update
helm install nginx bitnami/nginx
helm install gitpod .
