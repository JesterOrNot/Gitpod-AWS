#!/bin/bash
set -ex
if [ -z $(which helm) ]; then
    wget "https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz" \
    && tar xvf helm-v3.0.2-linux-amd64.tar.gz \
    && sudo install linux-amd64/helm /usr/local/bin/
fi
if [ -z $(which kubectl) ]; then
    sudo apt-get install -y apt-transport-https
    curl -s "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
    printf '\nsource <(kubectl completion bash)\n' >>~/.bashrc
fi
if [ -z $(which aws) ]; then
    brew install awscli
fi
if [ -z $(which terraform) ]; then
    cd /tmp
    sudo mkdir terraform
    cd terraform
    sudo apt-get install unzip
    sudo wget "https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip"
    sudo unzip terraform_0.12.18_linux_amd64.zip
    chmod +x terraform
    sudo install terraform /usr/bin
    printf '\nterraform -install-autocomplete &>/dev/null\n' >>~/.bashrc
fi
if [ -z $(which git) ]; then
    sudo apt-get install -y git
fi