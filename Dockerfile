FROM debian:bullseye

ARG SGN_REPO
ARG SGN_BRANCH
ARG SGN_COMMIT

# create directory layout
#
# npm install needs a non-root user (new in latest version)
#
RUN useradd -d /home/production -u 1250 production 

RUN mkdir -p /home/production/public/sgn_static_content
RUN mkdir -p /home/production/cxgn
RUN mkdir -p /home/production/cxgn/local-lib
RUN mkdir /etc/starmachine
RUN mkdir /var/log/sgn

RUN chown -R production /home/production

WORKDIR /home/production/cxgn


# install system dependencies
#
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y --allow-unauthenticated && \
    apt-get upgrade -y && \
    apt-get install -y build-essential pkg-config apt-utils gnupg2 curl wget git \
                       npm libterm-readline-zoid-perl nginx starman emacs vim nano \
                       less sudo htop dkms linux-headers-generic perl-doc ack make \
                       xutils-dev nfs-common lynx xvfb ncbi-blast+ libmunge-dev libmunge2 \
                       munge slurm-wlm slurmctld slurmd libslurm-perl libssl-dev graphviz \
                       lsof imagemagick mrbayes muscle bowtie bowtie2 postfix mailutils \
                       libcupsimage2 libglib2.0-dev libglib2.0-bin screen \
                       apt-transport-https libgdal-dev libproj-dev libudunits2-dev locales \
                       locales-all rsyslog cron anacron libnlopt0

# Slurm setup
#
RUN rm /etc/munge/munge.key
RUN chmod 777 /var/spool/ \
    && mkdir /var/spool/slurmstate \
    && chown slurm:slurm /var/spool/slurmstate/ \
    && /usr/sbin/mungekey \
    && chown munge:munge /etc/munge/munge.key \
    && ln -s /var/lib/slurm-llnl /var/lib/slurm \
    && mkdir -p /var/log/slurm
RUN usermod -a -G postdrop www-data

# Add cran repo
#
RUN echo "deb https://cloud.r-project.org/bin/linux/debian/ bullseye-cran40/" >> /etc/apt/sources.list
RUN bash -c "apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' 1>/key.out 2> /key.err"

# Add postgresql repo
#
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add -

# Update repos
#
RUN apt-get update --fix-missing -y

# install postgres client
#
RUN apt-get install -y postgresql-client-12

# install R
#
RUN apt-get install r-base r-base-dev -y --allow-unauthenticated

# required for R-package spdep, and other dependencies of agricolae
#
RUN apt-get install libudunits2-dev libproj-dev libgdal-dev -y

# XML::Simple dependency
#
RUN apt-get install libexpat1-dev -y

# HTML::FormFu
#
RUN apt-get install libcatalyst-controller-html-formfu-perl -y

# Cairo Perl module needs this:
#
RUN apt-get install libcairo2-dev -y

# GD Perl module needs this:
#
RUN apt-get install libgd-dev -y

# postgres driver DBD::Pg needs this:
#
RUN apt-get install libpq-dev -y

# MooseX::Runnable Perl module needs this:
#
RUN apt-get install libmoosex-runnable-perl -y

RUN apt-get install libgdbm6 libgdm-dev -y
RUN apt-get install nodejs -y

# Install extra Perl modules
RUN curl -L https://cpanmin.us | perl - --sudo App::cpanminus
RUN cpanm --force Selenium::Remote::Driver@1.44 Sort::Naturally Cache::FastMmap

#INSTALL OPENCV IMAGING LIBRARY
RUN apt-get install -y python3-dev  python3-pip python3-numpy libgtk2.0-dev libgtk-3-0 libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev libhdf5-serial-dev libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libxvidcore-dev libatlas-base-dev gfortran libgdal-dev exiftool libzbar-dev cmake
RUN pip3 install --upgrade pip
RUN pip3 install grpcio==1.40.0 imutils numpy matplotlib pillow statistics PyExifTool pytz pysolar scikit-image packaging pyzbar pandas opencv-python \
    && pip3 install -U keras-tuner

# copy some tools that don't have a Debian package
#
COPY tools/gcta/gcta64  /usr/local/bin/
COPY tools/quicktree /usr/local/bin/
COPY tools/sreformat /usr/local/bin/
COPY tools/fix_file_permissions /usr/local/bin/
COPY tools/set_git_info /usr/local/bin/
COPY tools/DiGGer_1.0.5_R_x86_64-redhat-linux-gnu.tar.gz /home/production/DiGGer.tar.gz

# Install DiGGer from the source code
# 
RUN R CMD INSTALL /home/production/DiGGer.tar.gz

# build htslib (tabix) for T3 download-vcf.pl script
# 
WORKDIR /htslib
RUN git clone https://github.com/samtools/htslib .
RUN git submodule update --init --recursive
RUN make
RUN make install
WORKDIR /home/production/cxgn
RUN rm -rf /htslib

# clone git repos directly from github
WORKDIR /home/production/cxgn
USER production
RUN git clone --depth 20 -b $SGN_BRANCH             https://github.com/$SGN_REPO.git                        ./sgn
RUN git clone --depth 1                             https://github.com/solgenomics/cxgn-corelibs.git        ./cxgn-corelibs
RUN git clone --depth 1                             https://github.com/solgenomics/Phenome.git              ./Phenome
RUN git clone --depth 1                             https://github.com/solgenomics/rPackages.git            ./rPackages
RUN git clone --depth 1                             https://github.com/solgenomics/biosource.git            ./biosource
RUN git clone --depth 1                             https://github.com/solgenomics/Cview.git                ./Cview
RUN git clone --depth 1                             https://github.com/solgenomics/ITAG.git                 ./ITAG
RUN git clone --depth 1                             https://github.com/solgenomics/tomato_genome.git        ./tomato_genome
RUN git clone --depth 1                             https://github.com/solgenomics/sgn-devtools.git         ./sgn-devtools
RUN git clone --depth 1                             https://github.com/solgenomics/solGS.git                ./solGS
RUN git clone --depth 1                             https://github.com/solgenomics/starmachine.git          ./starmachine
RUN git clone --depth 1                             https://github.com/GMOD/chado_tools.git                 ./chado_tools
RUN git clone --depth 1                             https://github.com/solgenomics/bio-chado-schema.git     ./Bio-Chado-Schema
RUN git clone --depth 1                             https://github.com/solgenomics/DroneImageScripts.git    ./DroneImageScripts
RUN git clone --depth 1 -b topic/debian_bullseye    https://github.com/solgenomics/perl-local-lib.git       ./local-lib
RUN git clone --depth 1 -b master                   https://github.com/solgenomics/R_libs.git               ./R_libs
RUN git clone --depth 1                             https://github.com/solgenomics/QuantGenResources.git    ./QuantGenResources
RUN git clone --depth 1 -b triticum                 https://github.com/TriticeaeToolbox/mason.git           ./triticum
RUN git clone --depth 1 -b triticum-sandbox         https://github.com/TriticeaeToolbox/mason.git           ./triticum_sandbox
RUN git clone --depth 1 -b triticum-cap             https://github.com/TriticeaeToolbox/mason.git           ./triticum_cap
RUN git clone --depth 1 -b triticum-uiuc            https://github.com/TriticeaeToolbox/mason.git           ./triticum_uiuc
RUN git clone --depth 1 -b triticum-arsks           https://github.com/TriticeaeToolbox/mason.git           ./triticum_arsks
RUN git clone --depth 1 -b avena                    https://github.com/TriticeaeToolbox/mason.git           ./avena
RUN git clone --depth 1 -b avena-sandbox            https://github.com/TriticeaeToolbox/mason.git           ./avena_sandbox
RUN git clone --depth 1 -b avena-private            https://github.com/TriticeaeToolbox/mason.git           ./avena_private
RUN git clone --depth 1 -b hordeum                  https://github.com/TriticeaeToolbox/mason.git           ./hordeum
RUN git clone --depth 1 -b hordeum-sandbox          https://github.com/TriticeaeToolbox/mason.git           ./hordeum_sandbox
RUN git clone --depth 1                             https://github.com/TriticeaeToolbox/kelp.git            ./kelp
USER root

# move this here so it is not clobbered by the cxgn move
#
COPY etc/slurm.conf /etc/slurm/slurm.conf
COPY etc/starmachine.conf /etc/starmachine/
COPY etc/nginx.conf /etc/nginx/sites-available/default
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set clear_old_temp_files script to run daily
RUN ln -s /home/production/cxgn/sgn/bin/clear_old_temp_files.sh /etc/cron.daily/clear_sgn_temp

# Add /home/production/volume directory, which is expected by some caches and the CXGN::Jobs log
RUN mkdir -p /home/production/volume && chown www-data:www-data /home/production/volume

ARG DOCKER_TAG
ARG DOCKER_CREATED

ENV CPANMIRROR=http://cpan.cpantesters.org
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8
ENV PERL5LIB=/home/production/cxgn/Bio-Chado-Schema/lib:/home/production/cxgn/local-lib/:/home/production/cxgn/local-lib/lib/perl5:/home/production/cxgn/sgn/lib:/home/production/cxgn/cxgn-corelibs/lib:/home/production/cxgn/Phenome/lib:/home/production/cxgn/Cview/lib:/home/production/cxgn/ITAG/lib:/home/production/cxgn/biosource/lib:/home/production/cxgn/tomato_genome/lib:/home/production/cxgn/chado_tools/chado/lib:.
ENV HOME=/home/production
ENV PGPASSFILE=/home/production/.pgpass
ENV R_LIBS_USER=/home/production/cxgn/R_libs

RUN locale-gen en_US.UTF-8
RUN echo "R_LIBS_USER=/home/production/cxgn/R_libs" >> /etc/R/Renviron
RUN ln -s /home/production/cxgn/starmachine/bin/starmachine_init.d /etc/init.d/sgn

LABEL maintainer="djw64@cornell.edu"
LABEL org.opencontainers.image.authors="Breedbase - https://github.com/solgenomics/sgn, The Triticeae Toolbox - https://github.com/TriticeaeToolbox/sgn"
LABEL org.opencontainers.image.created=$DOCKER_CREATED
LABEL org.opencontainers.image.url="https://hub.docker.com/r/triticeaetoolbox/breedbase_web"
LABEL org.opencontainers.image.source="https://github.com/TriticeaeToolbox/breedbase_dockerfile"
LABEL org.opencontainers.image.version=$DOCKER_TAG
LABEL org.opencontainers.image.revision=$SGN_COMMIT
LABEL org.opencontainers.image.vendor="The Triticeae Toolbox"
LABEL org.opencontainers.image.title="T3/Breedbase"
LABEL org.opencontainers.image.description="The web server for T3/Breedbase"
LABEL org.opencontainers.image.documentation="https://solgenomics.github.io/sgn/"

# start services when running container...
WORKDIR /home/production/cxgn/sgn
EXPOSE 80 8080
ENTRYPOINT ["/entrypoint.sh"]
