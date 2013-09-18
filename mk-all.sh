#!/bin/bash
set -e
pushd thread-sanitizer
./mk.sh
popd thread-sanitizer
echo "done!"
