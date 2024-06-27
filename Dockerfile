# Use the official Alpine base image
FROM alpine:latest

# Set environment variables
ENV TERRAFORM_VERSION=1.5.6

# Update and install basic packages including bash, git, curl, python3, and openjdk 17
RUN apk update && \
    apk add --no-cache \
    bash \
    git \
    curl \
    python3 \
    py3-pip \
    openjdk17-jdk

# Install Terraform
RUN apk add --no-cache --virtual .build-deps \
    unzip \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && apk del .build-deps

# Verify installations
RUN terraform -v && \
    git --version && \
    python3 --version && \
    java -version

EXPOSE 80
# Set default shell to bash
CMD ["/bin/bash"]