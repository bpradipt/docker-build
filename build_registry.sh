#!/bin/bash
#
#Script to build registry on Power
#
#Requires go compiler to be available in the PATH
#
# build_registry.sh [static|dynamic] [build_rpm]
# build_rpm is either 'y' or 'n'

build_type=${1}
build_rpm=${2}

BUILD_TYPE=${build_type:-dynamic}
BUILD_RPM=${build_rpm:-n}

SRC="https://github.com/docker/distribution.git"
COMMIT_ID=ece8e132bf6585815fdd00990f6215122c58fb3f

#Install git

yum install -y git

CUR_DIR=`pwd`
INSTALL_DIR="${CUR_DIR}/go.bld"
BIN_DIR="${CUR_DIR}/go.bld/bin"
mkdir -p ${BIN_DIR}
GOPATH_BASE="${INSTALL_DIR}/src/github.com/docker"
mkdir -p ${GOPATH_BASE}
cd ${GOPATH_BASE}
git clone ${SRC}
cd distribution
git checkout -q ${COMMIT_ID}
export GOPATH="${GOPATH_BASE}/distribution/Godeps/_workspace:${INSTALL_DIR}:${GOPATH}"
if [ "${BUILD_TYPE}" == "static" ]
then
    BUILDFLAGS="-static -lnetgo"
else
    BUILDFLAGS=""
fi

go build -gccgoflags "${BUILDFLAGS}" -o ${BIN_DIR}/registry ./cmd/registry

#To use the registry you need to copy the file cmd/registry/config-example.yml as config.yml and run it
#./registry ./config.yml
cp ./cmd/registry/config-example.yml ${BIN_DIR}/config.yml

if [ "${BUILD_RPM}" == "y" ]
then
    #build rpm
    #Version for RPM
    GIT_UNIX="$(git log -1 --pretty='%at')"
    GIT_DATE="$(date --date "@$GIT_UNIX" +'%Y%m%d')"
    GIT_COMMIT="$(git log -1 --pretty='%h')"
    GIT_VERSION="${GIT_DATE}git${GIT_COMMIT}"
    #GIT_VERSION is now something like '20150128git17e840a'
    rpmbuild --define="checkout ${GIT_VERSION}"  --define="version 2.1.1" \
        --define="_filepath ${BIN_DIR}" -bb ${CUR_DIR}/registry.spec
fi

