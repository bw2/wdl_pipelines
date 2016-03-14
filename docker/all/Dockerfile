FROM weisburd/vep_with_cache:83_GRCh37

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

# grabix
RUN cd /root && \
    git clone https://github.com/arq5x/grabix.git && \
    cd grabix && \
    make

ENV PATH /root/grabix:$PATH

# vt
RUN cd /root && \
    git clone https://github.com/atks/vt.git && \
    cd vt && \
    make && \
    make test

RUN rm -rf *.* Makefile lib test

ENV PATH /root/vt:$PATH
