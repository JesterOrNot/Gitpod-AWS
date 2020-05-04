FROM gitpod/workspace-full
USER gitpod
ENV TRIGGER_REBUILD=2
RUN brew install shellharden shfmt shellcheck
# Install aws-iam-authenticator
RUN curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator" \
    && chmod +x ./aws-iam-authenticator \
    && sudo install aws-iam-authenticator /usr/bin
# Install networking tools
RUN sudo apt-get update \
    && sudo apt-get install -yq \
        tcpdump \
        iputils-ping
ENV PATH=$PATH:$HOME/.aws-iam
COPY . /tmp
WORKDIR /tmp
RUN ./deps.sh
