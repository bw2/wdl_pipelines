FROM pypy:2-5

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

# update, install CLI tools
RUN apt-get update && \
    apt-get install -y unzip

RUN cd /root && \
    git clone https://github.com/arq5x/grabix.git && \
    cd grabix && \
    make

WORKDIR /root/grabix

ENV PATH /root/grabix:$PATH

CMD ["pypy"]
