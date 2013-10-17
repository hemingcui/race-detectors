#!/bin/bash
set -e
pushd thread-sanitizer
./mk.sh
popd
pushd thread-sanitizer-2
./mk.sh
popd
pushd relay
./mk.sh
popd
echo "please set the environment variable DATA_RACE_DETECTION_ROOT to `pwd`"
echo "done!"
