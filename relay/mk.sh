#!/bin/bash
set -e
sudo apt-get install ocaml
pushd /usr/lib/ocaml
sudo ln -s libcamlstr.a libstr.a
popd
rm relay-radar.0.10.03.tar.gz
wget http://cseweb.ucsd.edu/~jvoung/code/relay-radar.0.10.03.tar.gz
tar -xvzf relay-radar.0.10.03.tar.gz
cd relay-radar
pushd cil
./configure
make
make check
popd
make
cd scripts
patch myld.pl < ../../ld.patch
