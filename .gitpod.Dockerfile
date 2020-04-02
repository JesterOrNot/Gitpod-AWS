FROM gitpod/workspace-full

USER gitpod

RUN brew install terraform

RUN brew install kubectl \
    && kubectl completion bash >/etc/bash_completion.d/kubectl

WORKDIR /tmp/awscli

# Install AWS CLI
RUN sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && cd .. \
    && sudo rm -rf awscli
