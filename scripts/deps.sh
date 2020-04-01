#!/bin/bash
if [ command -v helm ] 2>/dev/null; then
    wget "https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz" \
    && tar xvf helm-v3.0.2-linux-amd64.tar.gz \
    && sudo mv linux-amd64/helm /usr/local/bin/
fi
