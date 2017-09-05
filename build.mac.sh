#!/bin/bash

set -e
set -x

cd "$(dirname "$0")"

sed -i -e 's/add_subdirectory\(docs\)/#add_subdirectory\(docs\)/g' curl/CMakeLists.txt

if [ -f buildmac32 ]; then
    rm -Rf buildmac32
fi
mkdir buildmac32
cd buildmac32
cmake -G "Xcode" -D CMAKE_OSX_ARCHITECTURES=i386 -D OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include ..
xcodebuild -project HiveMP.ClientConnect.xcodeproj -configuration Release build

cd "$(dirname "$0")"

if [ -f buildmac64 ]; then
    rm -Rf buildmac64
fi
mkdir buildmac64
cd buildmac64
cmake -G "Xcode" -D CMAKE_OSX_ARCHITECTURES=x86_64 -D OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include ..
xcodebuild -project HiveMP.ClientConnect.xcodeproj -configuration Release build