FROM gitpod/workspace-full

USER gitpod

RUN brew install terraform kubectl \
    && sudo env "PATH=$PATH" bash -c "echo 'source <(kubectl completion bash)' >>~/.bashrc \
        && terraform -install-autocomplete"

WORKDIR /tmp/awscli

# Install AWS CLI
RUN sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && cd .. \
    && sudo rm -rf awscli \
    && bash -c "complete -C '/usr/local/bin/aws_completer' aws"
