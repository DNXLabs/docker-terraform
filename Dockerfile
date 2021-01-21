FROM alpine:3.7

ENV TERRAFORM_VERSION=0.14.5
ENV AWSCLI_VERSION=1.18.173


VOLUME ["/work"]

WORKDIR /work

RUN apk update && \
    apk --no-cache add \
    bash=4.4.19-r1 \
    ca-certificates=20190108-r0 \
    git=2.15.4-r0 \
    openssl=1.0.2t-r0 \
    unzip=6.0-r3 \
    wget=1.20.3-r0 \
    curl=7.61.1-r3 \
    make=4.2.1-r0

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -P /tmp && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin

RUN apk --no-cache add \
    python=2.7.15-r3 \
    py-pip=9.0.1-r1 \
    py-setuptools=33.1.1-r1 \
    groff=1.22.3-r2 \
    less=520-r0 \
    jq=1.5-r5 \
    gettext-dev=0.19.8.1-r1 \
    g++=6.4.0-r5 \
    zip=3.0-r4 && \
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

