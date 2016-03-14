FROM alpine:latest

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

# update, install CLI tools
RUN apk update && apk add git gcc libgcc libstdc++ make g++ zlib-dev

RUN cd /root && \
    git clone https://github.com/arq5x/grabix.git && \
    cd grabix && \
    make

WORKDIR /root/grabix

ENV PATH /root/grabix:$PATH

CMD ["grabix"]
