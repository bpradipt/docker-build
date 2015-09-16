#!/bin/bash
#
#Script to build registry on Power
#
#Requires go compiler to be available in the PATH
#
# build_registry.sh

SRC="https://github.com/docker/distribution.git"
COMMIT_ID=ece8e132bf6585815fdd00990f6215122c58fb3f

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
go build -o ${BIN_DIR}/registry ./cmd/registry

#To use the registry you need to copy the file cmd/registry/config-example.yml as config.yml and run it 
#./registry ./config.yml

