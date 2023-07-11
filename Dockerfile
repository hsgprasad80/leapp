FROM cloudposse/geodesic:latest-debian as base

# Install ubuntu universe repo so we can install more helpful packages
# RUN apt-get install -y software-properties-common && \
#     add-apt-repository "deb http://archive.ubuntu.com/ubuntu bionic universe" && \
#     gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv 3B4FE6ACC0B21F32 && \
#     gpg --export --armor 3B4FE6ACC0B21F32 | apt-key add - && \
#     apt-get update && \
#     apt-get install -y golang-petname

ENV TFVERSIONUNO=1.2.9
ENV TFFIFTEEN=0.15.5
#ENV RANCHER_CLI_VERSION=v2.7.0

RUN wget https://releases.hashicorp.com/terraform/${TFVERSIONUNO}/terraform_${TFVERSIONUNO}_linux_amd64.zip && unzip terraform_${TFVERSIONUNO}_linux_amd64.zip && mkdir -p /usr/share/terraform/1.0/bin && mv terraform /usr/share/terraform/1.0/bin/terraform && cp /usr/share/terraform/1.0/bin/terraform /usr/bin/terraform
RUN wget https://releases.hashicorp.com/terraform/${TFFIFTEEN}/terraform_${TFFIFTEEN}_linux_amd64.zip && unzip terraform_${TFFIFTEEN}_linux_amd64.zip && mkdir -p /usr/share/terraform/0.15/bin && mv terraform /usr/share/terraform/0.15/bin/terraform
RUN cp /usr/share/terraform /usr/local/ -R

RUN apt update && apt upgrade -yq
RUN apt autoremove -yq

#ENV INFRACOST_API_KEY=

RUN apt install nano gnupg -yq

RUN curl -s -L https://github.com/infracost/infracost/releases/latest/download/infracost-linux-amd64.tar.gz | tar xz -C /tmp && sudo mv /tmp/infracost-linux-amd64 /usr/local/bin/infracost

ENV ASSUME_ROLE_INTERACTIVE=false
# Needed because multi provider started failing with wsl and dynamic linking
ENV TF_PLUGIN_CACHE_DIR=/tmp

# Geodesic 
ENV LESS=R
ENV DIRENV_ENABLED=true
ENV GEODESIC_TERRAFORM_WORKSPACE_PROMPT_ENABLED=true
ENV GEODESIC_TF_PROMPT_ACTIVE=true
ENV MAKE_INCLUDES="Makefile Makefile.*"
ENV KUBECONFIG=/dev/shm/kubecfg
ENV ASSUME_ROLE_INTERACTIVE=false
ENV TF_PLUGIN_CACHE_DIR=/tmp

#RUN wget https://github.com/rancher/rke/releases/download/v1.4.1/rke_linux-amd64 -O /usr/bin/rke && chmod +x /usr/bin/rke
#RUN wget https://github.com/aquasecurity/tfsec/releases/latest/download/tfsec-linux-amd64 -O /usr/bin/tfsec && chmod +x /usr/bin/tfsec

#RUN curl -sSL "https://github.com/rancher/cli/releases/download/${RANCHER_CLI_VERSION}/rancher-linux-amd64-${RANCHER_CLI_VERSION}.tar.gz" | tar -xz -C /usr/bin/ --strip-components=2
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar -xz -C /usr/local/bin
RUN pip install pre-commit

# Geodesic banner
ENV BANNER="dev.srv.uk"

# AWS Region
ENV AWS_REGION="eu-west-2"

# Terraform vars
ENV TF_VAR_region="${AWS_REGION}"
ENV TF_VAR_account_id="887791561963"
ENV TF_VAR_namespace="guru"
ENV TF_VAR_stage="prod"

# Terraform State Bucket
ENV TF_BUCKET_REGION="${AWS_REGION}"
ENV TF_BUCKET_PREFIX_FORMAT="basename-pwd"
ENV TF_BUCKET="${TF_VAR_namespace}-${TF_VAR_stage}-terraform-state"
ENV TF_BUCKET_ENCRYPT="true"
ENV TF_DYNAMODB_TABLE="${TF_VAR_namespace}-${TF_VAR_stage}-terraform-state-lock"

# Default AWS Profile name
ENV AWS_DEFAULT_PROFILE="${TF_VAR_namespace}-${TF_VAR_stage}-admin"
ENV AWS_PROFILE="${TF_VAR_namespace}-${TF_VAR_stage}-admin"

# Filesystem entry for tfstate
RUN s3 fstab "${TF_BUCKET}" "/" "/secrets/tf"

WORKDIR /conf/
