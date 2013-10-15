#!/bin/bash
PREFIX=$HOME
rm -rf llvm
svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm
pushd llvm
R=$(svn info | grep Revision: | awk '{print $2}')
(cd tools && svn co -r $R http://llvm.org/svn/llvm-project/cfe/trunk clang)
(cd projects && svn co -r $R http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt)
mkdir build
pushd build
CC=gcc-4.5 CXX=g++-4.5 ../configure --prefix=$PREFIX --enable-assertions --enable-debug-runtime --enable-optimized
make -j25 && make -j25 install || exit 1
popd
popd
rm -rf gcc
svn co svn://gcc.gnu.org/svn/gcc/trunk gcc
cd gcc && mkdir build && cd build
../configure --prefix=$PREFIX --enable-languages=c,c++ --disable-bootstrap --enable-checking=no
make -j25 && make install -j25 || exit 1
