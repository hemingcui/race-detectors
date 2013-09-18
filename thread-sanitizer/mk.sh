#!/bin/bash
rm -rf drt get_and_build_tsan.sh
wget http://data-race-test.googlecode.com/svn/trunk/tsan/get_and_build_tsan.sh
chmod +x ./get_and_build_tsan.sh
patch -p0 < make_script.patch
./get_and_build_tsan.sh `pwd`/install
