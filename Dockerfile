FROM alpine:3.13

ENV TERRAFORM_VERSION=0.15.3
ENV AWSCLI_VERSION=1.19.73


VOLUME ["/work"]

WORKDIR /work

RUN apk --no-cache update && \
    apk --no-cache add \
    bash \
    ca-certificates \
    git \
    openssl \
    unzip \
    wget \
    curl \
    make

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -P /tmp && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin

RUN apk --no-cache add \
    python3-dev \
    py3-pip \
    py-setuptools \
    groff \
    less \
    jq \
    gettext-dev \
    g++ \
    zip && \
    pip --no-cache-dir install awscli==$AWSCLI_VERSION && \
    update-ca-certificates && \
    rm -rf /var/tmp/ && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/*

COPY scripts /opt/scripts
RUN chmod 777 /opt/scripts/*
ENV PATH "$PATH:/opt/scripts"

ENTRYPOINT [ "terraform" ]


CMD [ "--version" ]

