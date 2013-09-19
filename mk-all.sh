#!/bin/bash
set -e
pushd thread-sanitizer
./mk.sh
popd thread-sanitizer
echo "please set the environment variable DATA_RACE_DETECTION_ROOT to `pwd`"
echo "done!"
