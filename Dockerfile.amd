FROM quay.io/pawsey/rocm-mpich-base:rocm6.3.0-mpich3.4.3-ubuntu24.04

# ROCm environment
ENV ROCM_RELEASE 6.3.0
ENV ROCM_PATH /opt/rocm-$ROCM_RELEASE
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV PIP_ROOT_USER_ACTION=ignore
ENV PIP_NO_CACHE_DIR=1

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update --quiet && \
    apt-get install --no-install-recommends --yes --quiet \
    build-essential \
    time \
    git \
    libgsl-dev \
    libboost-all-dev \
    libsuitesparse-dev \
    liblpsolve55-dev \
    libsqlite3-dev \
    libmysql++-dev \
    libboost-iostreams-dev \
    libbamtools-dev \
    samtools \
    libhts-dev \
    cdbfasta \
    libfile-which-perl \
    libparallel-forkmanager-perl \
    libyaml-perl \
    libdbd-mysql-perl \
    bamtools \
    bedtools \
    diamond-aligner \
    seqkit \
    transdecoder \
    minimap2 \
    perl \
    libdb-dev \
    zlib1g-dev \
    ca-certificates \
    && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

    # Install cpanm + Perl modules (URI includes URI::Escape)
RUN curl -fsSL https://cpanmin.us | perl - App::cpanminus && \
    cpanm --notest DB_File && \
    cpanm --notest URI

RUN pip install \
    setuptools \
    wheel \
    "hatchling>=1.26" \
    "packaging>=24.0" \
    "pyfamsa<0.6.0" \
    pyyaml \
    pyBigWig \
    bio \
    scikit-learn \
    biopython \
    bcbio-gff \
    requests && \
    pip install tensorflow-rocm==2.16.2 -f https://repo.radeon.com/rocm/manylinux/rocm-rel-6.3/ --upgrade && \
    pip install --no-deps learnMSA


COPY . /opt

WORKDIR /opt

RUN cd Augustus && \
    make clean && \
    make && \
    make install

RUN cd Tiberius && \
    pip install . && \
    chmod +x tiberius.py && \
    chmod +x tiberius/*py && \
    mkdir -p /opt/Tiberius/model_weights && \
    chmod -R 777 /opt/Tiberius/model_weights && \
    ln -s /opt/Tiberius/tiberius.py /usr/local/bin/tiberius

RUN cd EvidencePipeline/EvidencePipeline/scripts && \
    chmod +x *py

RUN cd miniprot-boundary-scorer && make

ENV PATH=/usr/local/bin/:${PATH}:/opt/Augustus/bin/:/opt/Tiberius/tiberius/:/opt/Tiberius/:/opt/EvidencePipeline/EvidencePipeline/scripts/:/opt/TransDecoder/util:/opt/miniprothint:/opt/miniprot-boundary-scorer:/opt/hisat2-2.2.1/:/opt/stringtie-3.0.3.Linux_x86_64:/opt/sratoolkit.3.3.0-ubuntu64/bin/
