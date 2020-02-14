FROM alpine:3.7

ENV TERRAFORM_VERSION=0.12.20
ENV AWSCLI_VERSION=1.17.14

VOLUME ["/work"]

WORKDIR /work

RUN apk update && \
    apk add bash ca-certificates git openssl unzip wget make && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin


RUN apk --no-cache add python py-pip py-setuptools groff less jq gettext-dev curl wget g++ zip && \
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

