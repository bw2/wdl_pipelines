FROM perl:latest

MAINTAINER Ben Weisburd <weisburd@broadinstitute.org>

WORKDIR /root

ENV PERL_MM_USE_DEFAULT=1

# update, install CLI tools
RUN apt-get update && \
    apt-get install -y unzip

# install bgzip and tabix
RUN cd /root && \
    wget https://github.com/samtools/htslib/archive/1.3.tar.gz && \
    tar xzf 1.3.tar.gz && \
    cd htslib-1.3 && \
    make && \
    mv bgzip tabix /bin/ && \
    cd .. && \
    rm -rf 1.3.tar.gz htslib-1.3 

# download / install VEP scripts
RUN cd /root && \
    wget https://github.com/Ensembl/ensembl-tools/archive/release/83.zip && \
    unzip 83.zip && \
    rm 83.zip

RUN cpan Archive::Extract DBI CGI Archive::Zip File::Copy::Recursive   # JSON Sereal -- these 2 additional perl modules are used by VEP tests. Leaving them out for now until they're needed

RUN cd /root/ensembl-tools-release-83/scripts/variant_effect_predictor && \
    perl INSTALL.pl --AUTO ap --PLUGINS all --NO_HTSLIB

RUN cd /root/.vep && \
    wget ftp://ftp.ensembl.org/pub/release-83/variation/VEP/homo_sapiens_vep_83_GRCh37.tar.gz && \
    tar xzf homo_sapiens_vep_83_GRCh37.tar.gz && \
    rm homo_sapiens_vep_83_GRCh37.tar.gz

RUN cd /root/.vep/homo_sapiens && \
    wget ftp://ftp.ensembl.org/pub/release-75/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz && \
    gzip -d Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz

# download a patched copy of dbNSFP.pm - the patch hasn't been merged into master yet
RUN curl https://raw.githubusercontent.com/bw2/VEP_plugins/patch-1/dbNSFP.pm -o /root/.vep/Plugins/dbNSFP.pm

# download module needed by LoFTEE
RUN curl https://raw.githubusercontent.com/konradjk/loftee/master/splice_module.pl -o /root/.vep/Plugins/splice_module.pl

# run VEP to index the fasta file and make sure everything is installed correctly
RUN echo /dev/null | perl /root/ensembl-tools-release-83/scripts/variant_effect_predictor/variant_effect_predictor.pl \
        --format vcf --no_stats --cache --offline --dir /root/.vep/ --cache_version 83  --assembly GRCh37  \
        --fasta /root/.vep/homo_sapiens/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa  && \
     rm variant_effect_output.txt


# convert cache with tabix
#RUN cd /root/ensembl-tools-release-83/scripts/variant_effect_predictor && \
#    perl convert_cache.pl -species all -version all

ENV PATH /root/ensembl-tools-release-83/scripts/variant_effect_predictor:$PATH

CMD ["variant_effect_predictor.pl"]