FROM centos:7.6.1810

ENV GOLANG_VERSION="1.12.5"

ENV TERRAFORM_VERSION="0.11.13"
ENV TERRAFORM_SHA256SUM=5925cd4d81e7d8f42a0054df2aafd66e2ab7408dbed2bd748f0022cfe592f8d2

ENV TERRAGRUNT_VERSION="v0.18.1"

ENV OPENSHIFT_INSTALLER_VERSION="v0.15.0"

ENV OPENSHIFT_CLI_VERSION="4.0.22"

ENV ARGOCD_VERSION="v1.0.1"

ENV ARGO_VERSION="v2.3.0"

ENV EKSCTL_VERSION="0.1.28"

# Note: Latest version of kubectl may be found at:
# https://aur.archlinux.org/packages/kubectl-bin/
ENV KUBECTL_VERSION="v1.14.2"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v2.14.0"

ENV KOPS_VERSION="1.11.1"

ENV STERN_VERSION="1.10.0"

ENV ANSIBLE_VERSION="2.7.10"

ENV AWS_CLI_VERSION="1.16.140"

ENV AWS_MFA_PLUGIN="1.0.1"

ENV JFROG_CLI_VERSION="1.24.3"

WORKDIR /tmp

# Update packages
RUN yum update -y

# Install some base packages
RUN yum install -y git \
                   unzip \
                   wget \
                   jq \
                   vim \
                   tmux \ 
                   make \
    && yum install -y https://centos7.iuscommunity.org/ius-release.rpm \
    && yum install -y python36u python36u-libs python36u-devel python36u-pip \
    && pip3.6 install --upgrade pip \
    && yum clean all

# Install Docker
RUN yum install -y yum-utils device-mapper-persistent-data lvm2 \
    && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && yum install docker-ce docker-ce-cli containerd.io

# Install AWS CLI
RUN pip3.6 install awscli==${AWS_CLI_VERSION}
# Install Ansible
RUN pip3.6 install ansible==${ANSIBLE_VERSION}
# Install AWS Auth MFA Helper
# RUN pip3.6 install awscli-plugin-credential-mfa==${AWS_MFA_PLUGIN} \
#    && aws configure set plugins.credentials awscli_plugin_credential_mfa

# Install Terraform
RUN wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && sha256sum -c terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin \
    && rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN wget -q https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt \
    && chmod +x /usr/local/bin/terragrunt

# Install Golang
RUN wget -q https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz \ 
    && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && mkdir /root/go/ && mkdir /root/go/src && mkdir /root/go/bin
ENV PATH /usr/local/go/bin:$PATH
ENV GOPATH /root/go
ENV PATH /root/go/bin:$PATH

# Install kubectl
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl 

# Install helm
RUN wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm init --client-only

# Install stern
RUN wget -q https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64 -O /usr/local/bin/stern \
    && chmod +x /usr/local/bin/stern

# Install kops
RUN wget -q https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64 -O /usr/local/bin/kops \
    && chmod +x /usr/local/bin/kops

# Install openshift 4 installer
RUN wget -q https://github.com/openshift/installer/releases/download/${OPENSHIFT_INSTALLER_VERSION}/openshift-install-linux-amd64 -O /usr/local/bin/openshift-install \
    && chmod +x /usr/local/bin/openshift-install
    
RUN wget -q https://mirror.openshift.com/pub/openshift-v3/clients/${OPENSHIFT_CLI_VERSION}/linux/oc.tar.gz  \
  && tar -xvzf oc.tar.gz \
  && mv oc /usr/local/bin/
    
# Install Summon and AWS Provider
RUN wget -q https://storage.googleapis.com/summon/summon -O /usr/local/bin/summon \
    && chmod +x /usr/local/bin/summon \
    && mkdir /usr/local/lib/summon \
    && wget -q https://storage.googleapis.com/summon/summon-aws-secrets -O /usr/local/lib/summon/summon-aws-secrets \
    && chmod +x /usr/local/lib/summon/summon-aws-secrets

# Install eksctl
RUN wget -q https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_linux_amd64.tar.gz -O /usr/local/bin/eksctl \
    && chmod +x /usr/local/bin/eksctl

# install jfrog CLI
RUN wget -q https://bintray.com/jfrog/jfrog-cli-go/download_file?file_path=${JFROG_CLI_VERSION}%2Fjfrog-cli-linux-amd64%2Fjfrog -O /usr/local/bin/jfrog \
    && chmod +x /usr/local/bin/jfrog

# Install ArgoCD CLI 
RUN wget -q https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64 -O /usr/local/bin/argocd \
    && chmod +x /usr/local/bin/argocd

# Install Argo CLI
RUN wget -q https://github.com/argoproj/argo/releases/download/${ARGO_VERSION}/argo-linux-amd64 -O /usr/local/bin/argo \
    && chmod +x /usr/local/bin/argo

WORKDIR /config

