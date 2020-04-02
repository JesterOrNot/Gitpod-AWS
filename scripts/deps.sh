#!/bin/bash
if [ -x $(which helm) ]; then
    wget "https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz" \
    && tar xvf helm-v3.0.2-linux-amd64.tar.gz \
    && sudo mv linux-amd64/helm /usr/local/bin/
fi
