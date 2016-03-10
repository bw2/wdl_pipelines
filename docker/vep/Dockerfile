FROM perl:latest

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

WORKDIR /root

ENV PERL_MM_USE_DEFAULT=1

ADD https://github.com/Ensembl/ensembl-tools/archive/release/83.zip /root/

RUN apt-get update && \
    apt-get install -y unzip tabix && \
    unzip 83.zip && \
    rm 83.zip

RUN cpan Archive::Extract DBI CGI Archive::Zip File::Copy::Recursive   # JSON Sereal -- these 2 additional perl modules are used by VEP tests. Leaving them out for now until they're needed

RUN cd /root/ensembl-tools-release-83/scripts/variant_effect_predictor && \
    perl INSTALL.pl --AUTO ap --PLUGINS all --NO_HTSLIB

# download a patched copy of dbNSFP.pm which hasn't been merged into master yet
ADD https://raw.githubusercontent.com/bw2/VEP_plugins/patch-1/dbNSFP.pm /root/.vep/Plugins/
