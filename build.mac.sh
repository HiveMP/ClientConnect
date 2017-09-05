#!/bin/bash

set -e
set -x

cd "$(dirname "$0")"
ROOT=$(pwd)
cd $ROOT

sed -i -e 's/add_subdirectory\(docs\)/#add_subdirectory\(docs\)/g' curl/CMakeLists.txt

# Builds are faster if we don't clear the CMake cache.
SHASUM=$(shasum CMakeLists.txt | awk '{print $1}')

if [ ! -d buildmac32_${SHASUM}_v1 ]; then
    mkdir buildmac32_${SHASUM}_v1
fi
cd buildmac32_${SHASUM}_v1
cmake -G "Xcode" -D CMAKE_OSX_ARCHITECTURES=i386 -D OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include ..
xcodebuild -project HiveMP.ClientConnect.xcodeproj -configuration Release build

cd $ROOT

if [ ! -d buildmac64_${SHASUM}_v1 ]; then
    mkdir buildmac64_${SHASUM}_v1
fi
cd buildmac64_${SHASUM}_v1
cmake -G "Xcode" -D CMAKE_OSX_ARCHITECTURES=x86_64 -D OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include ..
xcodebuild -project HiveMP.ClientConnect.xcodeproj -configuration Release build