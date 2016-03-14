#FROM alpine:latest
FROM buildpack-deps:jessie

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

# update, install CLI tools
#RUN apk update && apk add git gcc libgcc libstdc++ make g++ zlib-dev
RUN apt-get update

RUN cd /root && \
    git clone https://github.com/atks/vt.git && \
    cd vt && \
    make && \
    make test

RUN rm -rf *.* Makefile lib test


WORKDIR /root/vt

ENV PATH /root/vt:$PATH

CMD ["/root/vt/vt"]
