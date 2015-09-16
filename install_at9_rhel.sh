#!/bin/bash

#Add repo
cat <<EOF>/etc/yum.repos.d/at9_0.repo
[at9.0]
name=Advance Toolchain Unicamp FTP
baseurl=ftp://ftp.unicamp.br/pub/linuxpatch/toolchain/at/redhat/RHEL7
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=ftp://ftp.unicamp.br/pub/linuxpatch/toolchain/at/redhat/RHEL7/gpg-pubkey-6976a827-5164221b
EOF


yum install -y advance-toolchain-at9.0-runtime \
               advance-toolchain-at9.0-devel \
               advance-toolchain-at9.0-perf \
               advance-toolchain-at9.0-mcore-libs


echo "export PATH=/opt/at9.0/bin:/opt/at9.0/sbin:$PATH" >> /etc/profile.d/at9.sh

source /etc/profile.d/at9.sh

/opt/at9.0/sbin/ldconfig 
