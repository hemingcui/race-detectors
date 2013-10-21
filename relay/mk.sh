#!/bin/bash
set -e
sudo apt-get install ocaml
pushd /usr/lib/ocaml
if [ ! -f libstr.a ]; then
sudo ln -s libcamlstr.a libstr.a
fi
popd
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
