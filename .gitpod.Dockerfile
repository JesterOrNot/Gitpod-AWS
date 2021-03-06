FROM gitpod/workspace-full

USER gitpod

RUN sudo apt-get -qq update \
    && sudo apt-get install -yq letsencrypt

RUN brew install terraform kubectl shellharden shfmt shellcheck \
    && sudo env "PATH=$PATH" bash -c "printf 'source <(kubectl completion bash)\nterraform -install-autocomplete\n' >>~/.bashrc"

WORKDIR /tmp/awscli

# Install AWS CLI
RUN sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && sudo unzip awscliv2.zip \
    && sudo ./aws/install \
    && cd .. \
    && sudo rm -rf awscli \
    && bash -c "printf 'complete -C '/usr/local/bin/aws_completer' aws' >> ~/.bashrc"

# Install aws-iam-authenticator
RUN sudo curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator" \
    && sudo chmod +x ./aws-iam-authenticator \
    && sudo mkdir -p $HOME/.aws-iam \
    && sudo cp ./aws-iam-authenticator $HOME/.aws-iam/aws-iam-authenticator

COPY . /tmp

WORKDIR /tmp

RUN ./deps.sh

ENV PATH=$PATH:$HOME/.aws-iam:/workspace/Gitpod-AWS/scripts
