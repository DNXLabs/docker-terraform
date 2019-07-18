FROM alpine:3.7

ENV TERRAFORM_VERSION=0.12.4

VOLUME ["/work"]

WORKDIR /work

RUN apk update && \
    apk add bash ca-certificates git openssl unzip wget make && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/* 

ENTRYPOINT [ "terraform" ]

CMD [ "version" ]
