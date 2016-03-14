FROM weisburd/vep_with_cache:83_GRCh37

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>


# download data for VEP
RUN mkdir -p /root/.vep/loftee  /root/.vep/dbnsfp

RUN cd /root/.vep/loftee && \
    wget http://s3.amazonaws.com/bcbio_nextgen/human_ancestor.fa.gz

RUN cd /root/.vep/dbnsfp && \
    wget ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/dbNSFPv3.1a.zip

RUN cd /root/.vep/dbnsfp && \
    unzip dbNSFPv3.1a.zip && \
    cat dbNSFP*chr* | bgzip -c > dbNSFP.gz && \
    rm dbNSFPv3.1a.zip dbNSFP3.1* try* search_dbNSFP31a.* LICENSE.txt && \
    tabix -s 1 -b 2 -e 2 dbNSFP.gz

