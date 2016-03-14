FROM perl:latest

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

WORKDIR /root

ENV PERL_MM_USE_DEFAULT=1

# update, install CLI tools
RUN apt-get update && \
    apt-get install -y unzip

# download / install VEP scripts
RUN cd /root && \
    wget https://github.com/Ensembl/ensembl-tools/archive/release/83.zip && \
    unzip 83.zip && \
    rm 83.zip

RUN cpan Archive::Extract DBI CGI Archive::Zip File::Copy::Recursive   # JSON Sereal -- these 2 additional perl modules are used by VEP tests. Leaving them out for now until they're needed

RUN cd /root/ensembl-tools-release-83/scripts/variant_effect_predictor && \
    perl INSTALL.pl --AUTO ap --PLUGINS all --NO_HTSLIB

# download a patched copy of dbNSFP.pm - the patch hasn't been merged into master yet
RUN curl https://raw.githubusercontent.com/bw2/VEP_plugins/patch-1/dbNSFP.pm -o /root/.vep/Plugins/dbNSFP.pm

# download module needed by LoFTEE
RUN curl https://raw.githubusercontent.com/konradjk/loftee/master/splice_module.pl -o /root/.vep/Plugins/splice_module.pl

# set PATH
ENV PATH /root/ensembl-tools-release-83/scripts/variant_effect_predictor:$PATH

CMD ["variant_effect_predictor.pl"]