#!/bin/bash

set -e
set -x

cd "$(dirname "$0")"

sed -i -e 's/add_subdirectory\(docs\)/#add_subdirectory\(docs\)/g' curl/CMakeLists.txt

# Builds are faster if we don't clear the CMake cache.

#if [ -d buildmac32 ]; then
#    rm -Rf buildmac32
#fi
if [ ! -d buildmac32 ]; then
    mkdir buildmac32
fi
cd buildmac32
cmake -G "Xcode" -D CMAKE_OSX_ARCHITECTURES=i386 -D OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include ..
xcodebuild -project HiveMP.ClientConnect.xcodeproj -configuration Release build

cd "$(dirname "$0")"

if [ -d buildmac64 ]; then
    rm -Rf buildmac64
fi
if [ ! -d buildmac64 ]; then
    mkdir buildmac64
fi
cd buildmac64
cmake -G "Xcode" -D CMAKE_OSX_ARCHITECTURES=x86_64 -D OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include ..
xcodebuild -project HiveMP.ClientConnect.xcodeproj -configuration Release build