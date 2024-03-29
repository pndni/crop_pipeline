FROM centos:7.6.1810

RUN yum install -y epel-release
RUN yum install -y wget file bc tar gzip libquadmath which bzip2 libgomp tcsh perl less vim zlib zlib-devel hostname Lmod
RUN yum groupinstall -y "Development Tools"
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.sh
RUN mkdir -p /opt/cmake
RUN /bin/bash cmake-3.14.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN rm cmake-3.14.0-Linux-x86_64.sh

# ANTs
# it doesn't look like the libraries are needed. no RPATH or
# RUNPATH used. as determined by running
# for i in `ls`; do if [ $(file $i | awk '{print $2}') == "ELF" ]; then objdump -x $i | awk -v FS='\n' -v RS='\n\n' '$1 == "Dynamic Section:" {print}' | grep -i path ; fi; done;
# in /scif/apps/ants/bin
# and the documentation doesn't say to alter LD_LIBRARY_PATH
RUN tmpdir=$(mktemp -d) && \
    pushd $tmpdir && \
    git clone --branch v2.3.1 https://github.com/ANTsX/ANTs.git ANTs_src && \
    mkdir ANTs_build && \
    pushd ANTs_build && \
    /opt/cmake/bin/cmake ../ANTs_src -DITK_BUILD_MINC_SUPPORT=ON -DCMAKE_BUILD_TYPE=RELEASE && \
    make -j 2 && \
    popd && \
    mkdir -p /opt/ants/bin && \
    cp ANTs_src/Scripts/* /opt/ants/bin/ && \
    cp ANTs_build/bin/* /opt/ants/bin/ && \
    popd && \
    rm -rf $tmpdir
ENV PATH=/opt/ants/bin:$PATH

# python and dcm2niix stuff
RUN yum install -y python36 python36-pip python36-devel libstdc++-static pigz python36-virtualenv
RUN pip3.6 install numpy==1.16.3 scipy==1.2.1 bids-validator==1.2.4 pybids==0.9.4 nibabel==2.4.0 duecredit==0.7.0

RUN pip3.6 install git+https://github.com/stilley2/nipype.git@1.2.3-mod
RUN pip3.6 install git+https://github.com/pndni/pndniworkflows.git@505e113

RUN mkdir /opt/bin/
COPY crop_pipeline.py /opt/bin/
ENV PATH=/opt/bin:$PATH

ENTRYPOINT ["python3.6", "/opt/bin/crop_pipeline.py"]

ARG ver=dev
ARG builddate=""
ARG revision=""

LABEL org.opencontainers.image.title=crop_pipeline \
      org.opencontainers.image.source=https://github.com/pndni/crop_pipeline \
      org.opencontainers.image.url=https://github.com/pndni/crop_pipeline \
      org.opencontainers.image.version=$ver \
      org.opencontainers.image.created=$builddate \
      org.opencontainers.image.revision=$revision \
      org.label-schema.build-date=$builddate \
      org.label-schema.license=GPLv3 \
      org.label-schema.name=crop_pipeline \
      org.label-schema.schema-version=1.0.0-rc.1 \
      org.label-schema.url=https://github.com/pndni/crop_pipeline \
      org.label-schema.vcs-url=https://github.com/pndni/crop_pipeline \
      org.label-schema.vcs-ref=$revision \
      org.label-schema.vendor=""

LABEL Maintainer="Steven Tilley"

