FROM golang:1.13-alpine AS terraform-provider-aws

RUN apk add --update git bash openssh curl make bzr

ENV TERRAFORM_PROVIDER_COMMIT=923cc6ec11fbcdf97d260fc2621171888a327f00

ENV GO111MODULE=on
# Set the GOPROXY environment variable
ENV GOPROXY=https://goproxy.io
# ENV GOPROXY=https://gocenter.io
# ENV GO111MODULE="auto"
# ENV GOFLAGS=-mod=vendor

RUN mkdir -p /development/terraform-providers/ && \
    cd /development/terraform-providers/ && \
    git clone https://github.com/terraform-providers/terraform-provider-aws.git

WORKDIR /development/terraform-providers/terraform-provider-aws

RUN git checkout ${TERRAFORM_PROVIDER_COMMIT}

RUN make tools build

FROM alpine:3.7

ENV TERRAFORM_PROVIDER_PATCHED_VERSION=2.42.0-dnx-alb1

ENV TERRAFORM_VERSION=0.12.6
ENV AWSCLI_VERSION=1.16.169

VOLUME ["/work"]

WORKDIR /work

RUN mkdir -p /root/.terraform.d/plugins/

COPY --from=terraform-provider-aws /go/bin/terraform-provider-aws /root/.terraform.d/plugins/terraform-provider-aws_v${TERRAFORM_PROVIDER_PATCHED_VERSION}

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