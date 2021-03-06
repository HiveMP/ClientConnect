#!/bin/bash

set -e
set -x

cd "$(dirname "$0")"
ROOT=$(pwd)
cd $ROOT

sed -i -e 's/add_subdirectory\(docs\)/#add_subdirectory\(docs\)/g' curl/CMakeLists.txt

# Builds are faster if we don't clear the CMake cache.
SHASUM=$(shasum CMakeLists.txt | awk '{print $1}')
VERSION=v2

if [ -d buildlinux32_${SHASUM}_${VERSION} ]; then
    rm -Rf buildlinux32_${SHASUM}_${VERSION}
fi
mkdir buildlinux32_${SHASUM}_${VERSION}
cd buildlinux32_${SHASUM}_${VERSION}
cmake -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_TOOLCHAIN_FILE=../toolchain/Linux-i386.cmake ..
make

cd $ROOT

if [ -d buildlinux64_${SHASUM}_${VERSION} ]; then
    rm -Rf buildlinux64_${SHASUM}_${VERSION}
fi
mkdir buildlinux64_${SHASUM}_${VERSION}
cd buildlinux64_${SHASUM}_${VERSION}
cmake -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_TOOLCHAIN_FILE=../toolchain/Linux-x86_64.cmake ..
make

echo "Testing 32-bit binaries..."
cd $ROOT/buildlinux32_${SHASUM}_${VERSION}/Release
./HiveMP.SteamTest-exe | tee result.txt
if [ "$(cat result.txt | grep -c "TEST PASS")" != "2" ]; then
    echo "Test failed!"
    exit 1
fi

echo "Testing 64-bit binaries..."
cd $ROOT/buildlinux64_${SHASUM}_${VERSION}/Release
./HiveMP.SteamTest-exe | tee result.txt
if [ "$(cat result.txt | grep -c "TEST PASS")" != "2" ]; then
    echo "Test failed!"
    exit 1
fi

cd $ROOT

echo "Creating distribution structure..."
if [ -d dist ]; then
    rm -Rf dist
fi
mkdir -pv dist/sdk/Linux32
mkdir -pv dist/sdk/Linux64
cp buildlinux32_${SHASUM}_${VERSION}/Release/*.so dist/sdk/Linux32/
cp buildlinux64_${SHASUM}_${VERSION}/Release/*.so dist/sdk/Linux64/