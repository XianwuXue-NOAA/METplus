# This Dockerfile extends the MET image file to run METplus
#
# Build Arguments:
#
# OBTAIN_SOURCE_CODE - determines how to obtain source code
#   Options: clone (default), copy, or none
#
# MET_TAG - tag to use for obtaining MET image (default is develop)
#
# SOURCE_VERSION - optional branch/tag/commit to obtain from METplus repository
#   Only used if OBTAIN_SOURCE_CODE=clone
#

ARG OBTAIN_SOURCE_CODE=clone

ARG MET_TAG=develop

# if OBTAIN_SOURCE_CODE=copy, copy files from build context into image
FROM dtcenter/met:${MET_TAG} as build_copy
ONBUILD WORKDIR /metplus
ONBUILD RUN mkdir -p METplus
ONBUILD COPY . METplus
ONBUILD RUN if [ ! -e "METplus/ush/run_metplus.py" ]; then \
    echo "ERROR: docker build must be run from the METplus directory"; \
    exit 1; \
  fi

# if OBTAIN_SOURCE_CODE=clone, clone repository
FROM dtcenter/met:${MET_TAG} as build_clone
ONBUILD WORKDIR /metplus
ONBUILD ARG SOURCE_VERSION
ONBUILD RUN echo "Cloning METplus repository"; \
  git clone https://github.com/dtcenter/METplus; \
  if [ ! -z "${SOURCE_VERSION+x}" ]; then \
        echo "Checking out: ${SOURCE_VERSION}"; \
        cd METplus; \
        git checkout ${SOURCE_VERSION}; \
  fi

# if OBTAIN_SOURCE_CODE=none, do not retrieve files
FROM dtcenter/met:${MET_TAG} as build_none
ONBUILD WORKDIR /metplus

# use build alias based on OBTAIN_SOURCE_CODE value
FROM build_${OBTAIN_SOURCE_CODE}
MAINTAINER George McCabe <mccabe@ucar.edu>

RUN echo export PATH=$PATH:`pwd`/METplus/ush >> /etc/bashrc \
 && echo setenv PATH $PATH:`pwd`/METplus/ush >> /etc/csh.cshrc

# Install required packages: Pandas, Cartopy*
#  - *dateutil, pytest
#
# Install nco tools for ncap2
# Install Java 1.8.0 OpenJDK for GempakToCF.jar
# Install pytest and netCDF4 python packages
# Obtain GempakToCF.jar
RUN yum -y update \
 && yum -y install nco.x86_64 \
 && yum -y install java-1.8.0-openjdk \
 && python3 -m pip install pytest netCDF4 \
 && mkdir -p /data/input \
 && curl -L -o /data/input/GempakToCF.jar -O https://dtcenter.org/sites/default/files/community-code/metplus/utilities/GempakToCF.jar || true


# if source code was retrieved, set default config variables and install package
ARG OBTAIN_SOURCE_CODE=clone
RUN if [ ${OBTAIN_SOURCE_CODE} != "none" ]; then \
  echo "Installing METplus package and setting default configs"; \
  cd METplus; \
  sed -i 's|MET_INSTALL_DIR = /path/to|MET_INSTALL_DIR = /usr/local|g' parm/metplus_config/*.conf; \
  sed -i 's|OUTPUT_BASE = /path/to|OUTPUT_BASE = /data/output|g' parm/metplus_config/*.conf; \
  sed -i 's|INPUT_BASE = /path/to|INPUT_BASE = /data/input/METplus_Data|g' parm/metplus_config/*.conf; \
  python3 setup.py install; \
fi
