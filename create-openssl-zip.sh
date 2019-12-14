#!/bin/bash -x

# This file should be run inside the lambci/lambda:build-nodejs10.x container
yum update -y
yum install autoconf bison gcc gcc-c++ libcurl-devel libxml2-devel -y
curl -sL http://www.openssl.org/source/openssl-1.1.1d.tar.gz | tar -xvz
cd openssl-1.1.1d
./config --prefix=/var/task/nodejs/openssl --openssldir=/var/task/nodejs/openssl && make && make install
cd /var/task/
rm -rf nodejs/openssl/share
rm -rf nodejs/openssl/include
zip -r lambda-openssl-layer.zip nodejs
cp lambda-openssl-layer.zip /opt/layer/
