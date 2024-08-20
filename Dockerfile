FROM alpine:3.13

ENV TERRAFORM_VERSION=1.9.4
ENV AWSCLI_VERSION=1.19.73
ENV TERRAGRUNT_VERSION=v0.62.2


VOLUME ["/work"]

WORKDIR /work

RUN apk --no-cache update && \
    apk --no-cache add \
        bash \
        ca-certificates \
        git \
        openssl \
        unzip \
        zip \
        wget \
        curl \
        python3-dev \
        py3-pip \
        py-setuptools \
        groff \
        less \
        jq \
        gettext-dev \
        g++ \
        make && \
    pip --no-cache-dir install awscli==$AWSCLI_VERSION && \
    update-ca-certificates && \
    curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    rm -rf /var/tmp/ && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    wget -q https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

COPY scripts /opt/scripts
RUN chmod 777 /opt/scripts/*
ENV PATH "$PATH:/opt/scripts"

ENTRYPOINT [ "terraform" ]

CMD [ "--version" ]