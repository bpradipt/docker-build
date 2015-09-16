#!/bin/bash
#
#Script to build docker on RHEL 7 LE (ppc64le) platforms
#
# build_rhel7le.sh [dynamic|static] [build_dir]

#Build Type - dynamic|static
build_type=${1}
dir=${2}

BUILD_TYPE=${build_type:-static}
BUILD_DIR=${dir:-/docker_bld_ppc64}

SRC='https://github.com/docker/docker.git'
COMMIT_ID=611dbd8957581fa451a4103259100a5e2d115b8c

#Install required dependencies
yum update -y
yum groupinstall -y "Development Tools"
yum install -y libmpc-devel gcc-c++ flex patch glibc-static sqlite-devel \
    libselinux-static libsepol-static libsemanage-static pcre-static \
    lzo-devel libacl-devel e2fsprogs-devel asciidoc xmlto libffi-devel \
    btrfs-progs-devel device-mapper-devel expectk wget git

#Cleanup existing build and install directories
rm -fr ${BUILD_DIR}
rm -fr /usr/local/gcc5
rm -fr /usr/local/lvm2

#Create temp dir for building
mkdir -p ${BUILD_DIR}

#Build gcc-5 for go1.4
mkdir ${BUILD_DIR}/gcc5
cd ${BUILD_DIR}/gcc5

#Checkout GCC 5 branch
svn co svn://gcc.gnu.org/svn/gcc/branches/gcc-5-branch src
mkdir bld
cd bld
../src/configure --enable-threads=posix --enable-shared --enable-__cxa_atexit \
  --enable-languages=c,c++,go --enable-secureplt --enable-checking=yes \
  --with-long-double-128 --enable-decimal-float --disable-bootstrap \
  --disable-alsa --disable-multilib --prefix=/usr/local/gcc5

make
make install
echo /usr/local/gcc5/lib64 > /etc/ld.so.conf.d/gcc5.conf
ldconfig

export PATH=/usr/local/gcc5/bin:$PATH

#Build libseccomp
cd ${BUILD_DIR}
git clone https://github.com/seccomp/libseccomp.git
cd libseccomp
#Modify configure.ac to add explicit VERSION info
sed -i.bkp 's/VERSION_MAJOR=.*/VERSION=2.2.4\n&/' configure.ac
./autogen.sh
./configure
make install
mv configure.ac.bkp configure.ac



#Build xz static
cd ${BUILD_DIR}
git clone http://git.tukaani.org/xz.git
cd xz
./autogen.sh
./configure
make install

echo /usr/local/lib > /etc/ld.so.conf.d/xz.conf
ldconfig

#Build lvm2 static
git clone --no-checkout https://git.fedorahosted.org/git/lvm2.git ${BUILD_DIR}/lvm2
cd ${BUILD_DIR}/lvm2
git checkout -q v2_02_130
./configure --enable-static_link --prefix=/usr/local/lvm2
make device-mapper SELINUX_LIBS='-lselinux -lsepol -lpcre -llzma -lpthread -lm'
make install_device-mapper

export C_INCLUDE_PATH=/usr/local/lvm2/include
export LIBRARY_PATH=/usr/local/lvm2/lib:$LIBRARY_PATH
echo /usr/local/lvm2/lib > /etc/ld.so.conf.d/lvm.conf
ldconfig

#Build sqlite3 static
cd ${BUILD_DIR}
wget http://www.sqlite.org/2015/sqlite-src-3081001.zip
unzip sqlite-src-3081001.zip
cd sqlite-src-3081001
curl -o config.guess 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
curl -o autoconf/config.sub 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
./configure
make
make install

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

if [ ${BUILD_TYPE} == "dynamic" ]
then
    ./hack/make.sh dyngccgo
    sed -i.bkp 's/-ldl/-ldl -lselinux -lsepol -lpcre -llzma -lpthread -lsystemd-journal/g' hack/make/gccgo
else
    sed -i.bkp 's/-ldl/-ldl -lselinux -lsepol -lpcre -llzma -lpthread/g' hack/make/gccgo
    ./hack/make.sh gccgo
fi
mv ./hack/make/gccgo.bkp ./hack/make/gccgo
