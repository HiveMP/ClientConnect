#!/bin/bash

set -e
set -x

cd "$(dirname "$0")"
ROOT=$(pwd)
cd $ROOT

sed -i -e 's/add_subdirectory\(docs\)/#add_subdirectory\(docs\)/g' curl/CMakeLists.txt

# Builds are faster if we don't clear the CMake cache.
SHASUM=$(shasum CMakeLists.txt | awk '{print $1}')

if [ ! -d buildlinux32_${SHASUM}_v1 ]; then
    mkdir buildlinux32_${SHASUM}_v1
fi
cd buildlinux32_${SHASUM}_v1
cmake -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_TOOLCHAIN_FILE=../toolchain/Linux-i386.cmake ..
make

cd $ROOT

if [ ! -d buildlinux64_${SHASUM}_v1 ]; then
    mkdir buildlinux64_${SHASUM}_v1
fi
cd buildlinux64_${SHASUM}_v1
cmake -G "Unix Makefiles" -D CMAKE_BUILD_TYPE=Release -D CMAKE_TOOLCHAIN_FILE=../toolchain/Linux-x86_64.cmake ..
make

cd $ROOT

echo "Testing 32-bit binaries..."
cd $ROOT/buildlinux32_${SHASUM}_v1/Release
./HiveMP.SteamTest-exe | tee result.txt
if [ "$(cat result.txt | tr " " "\n" | grep -c "TEST PASS")" != "2" ]; then
    echo "Test failed!"
    exit 1
fi

echo "Testing 64-bit binaries..."
cd $ROOT/buildlinux64_${SHASUM}_v1/Release
./HiveMP.SteamTest-exe | tee result.txt
if [ "$(cat result.txt | tr " " "\n" | grep -c "TEST PASS")" != "2" ]; then
    echo "Test failed!"
    exit 1
fi

echo "Creating distribution structure..."
if [ -d dist ]; then
    rm -Rf dist
fi
mkdir -pv dist/sdk/Linux32
mkdir -pv dist/sdk/Linux64
cp buildlinux32_${SHASUM}_v1/Release/*.so dist/sdk/Linux32/
cp buildlinux64_${SHASUM}_v1/Release/*.so dist/sdk/Linux64/