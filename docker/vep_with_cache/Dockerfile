FROM perl:latest

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

WORKDIR /root

ENV PERL_MM_USE_DEFAULT=1

# download / install VEP scripts
RUN curl https://github.com/Ensembl/ensembl-tools/archive/release/83.zip -o /root/83.zip

RUN cpan Archive::Extract DBI CGI Archive::Zip File::Copy::Recursive   # JSON Sereal -- these 2 additional perl modules are used by VEP tests. Leaving them out for now until they're needed

RUN cd /root/ensembl-tools-release-83/scripts/variant_effect_predictor && \
    perl INSTALL.pl --AUTO ap --PLUGINS all --NO_HTSLIB

# update, install CLI tools
RUN apt-get update && \
    apt-get install -y unzip tabix bgzip && \
    unzip 83.zip && \
    rm 83.zip

# download and post-process data for VEP plugins
RUN curl http://s3.amazonaws.com/bcbio_nextgen/human_ancestor.fa.gz -o /root/.vep/loftee/human_ancestor.fa.gz

RUN curl ftp://ftp.ensembl.org/pub/release-83/variation/VEP/homo_sapiens_vep_83_GRCh37.tar.gz -o /root/.vep/homo_sapiens_vep_83_GRCh37.tar.gz && \
    cd /root/.vep/ && \
    tar xzf homo_sapiens_vep_83_GRCh37.tar.gz 
    
RUN curl ftp://dbnsfp:dbnsfp@dbnsfp.softgenetics.com/dbNSFPv3.1a.zip -o /root/.vep/dbnsfp/dbNSFPv3.1a.zip && \
    cd /root/.vep/dbnsfp && \
    unzip dbNSFPv3.1a.zip && \
    cat dbNSFP*chr* | bgzip -c > dbNSFP.gz && \
    tabix -s 1 -b 2 -e 2 dbNSFP.gz 

# download a patched copy of dbNSFP.pm - the patch hasn't been merged into master yet
RUN curl https://raw.githubusercontent.com/bw2/VEP_plugins/patch-1/dbNSFP.pm -o /root/.vep/Plugins/dbNSFP.pm

