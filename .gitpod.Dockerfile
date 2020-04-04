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

# Install aws-iam-authenticator
RUN sudo curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator" \
    && sudo chmod +x ./aws-iam-authenticator \
    && sudo mkdir -p $HOME/.aws-iam \
    && sudo cp ./aws-iam-authenticator $HOME/.aws-iam/aws-iam-authenticator
ENV PATH=$PATH:$HOME/.aws-iam

COPY . /tmp

WORKDIR /tmp

RUN ./deps.sh
