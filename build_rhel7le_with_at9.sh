#!/bin/bash
#
#Script to build docker on RHEL 7 LE (ppc64le) platforms using
#Advanced Toolchain
#
#Ensure AT9.0 is installed and PATH set appropriately
#
# build_rhel7le_with_at9.sh [build_dir]

dir=${1}

BUILD_DIR=${dir:-/docker_bld_ppc64}

SRC='https://github.com/docker/docker.git'
COMMIT_ID=611dbd8957581fa451a4103259100a5e2d115b8c

#Install required dependencies
yum groupinstall -y "Development Tools"
yum install -y patch sqlite-devel wget git \
    btrfs-progs-devel device-mapper-devel

#Cleanup existing build and install directories
rm -fr ${BUILD_DIR}

#Create temp dir for building
mkdir -p ${BUILD_DIR}

#Set GOPATH
GO_BASE_PATH="${BUILD_DIR}/go/src/github.com/docker/"
mkdir -p ${GO_BASE_PATH}
export AUTO_GOPATH=1

#Download docker source
cd ${GO_BASE_PATH}
git clone ${SRC}
cd docker
git checkout -b ppc64le ${COMMIT_ID}

curl https://github.com/bpradipt/docker/commit/567c796fba113bca56b4ebf82be93d813e21f0f2.patch | \
    patch -p1

sed -i.bkp 's/-ldl/-ldl -lpthread -lsystemd-journal/g' hack/make/gccgo
./hack/make.sh dyngccgo

mv ./hack/make/gccgo.bkp ./hack/make/gccgo
