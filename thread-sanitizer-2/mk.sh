#!/bin/bash
PREFIX=$HOME
rm -rf llvm
svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
cd llvm
R=$(svn info | grep Revision: | awk '{print $2}')
(cd tools && svn co -r $R http://llvm.org/svn/llvm-project/cfe/trunk clang)
(cd projects && svn co -r $R http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt)
mkdir build
cd build
CC=gcc-4.5 CXX=g++-4.5 ../configure --prefix=$PREFIX --enable-assertions --enable-debug-runtime --enable-optimized
make -j25 && make -j25 install || exit 1
