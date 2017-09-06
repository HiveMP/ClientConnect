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

cd $ROOT

if [ ! -d buildmac64_${SHASUM}_${VERSION} ]; then
    mkdir buildmac64_${SHASUM}_${VERSION}
fi
cd buildmac64_${SHASUM}_${VERSION}
cmake -G "Xcode" -D CMAKE_OSX_ARCHITECTURES=x86_64 -D OPENSSL_INCLUDE_DIR=/usr/local/opt/openssl/include ..
xcodebuild -project HiveMP.ClientConnect.xcodeproj -configuration Release build

echo "Testing 64-bit binaries..."
cd $ROOT/buildmac64_${SHASUM}_${VERSION}/Release
./HiveMP.SteamTest | tee result.txt
if [ "$(cat result.txt | grep -c "TEST PASS")" != "2" ]; then
    echo "Test failed!"
    exit 1
fi

cd $ROOT

echo "Creating distribution structure..."
if [ -d dist ]; then
    rm -Rf dist
fi
mkdir -pv dist/sdk/Mac64
cp buildmac64_${SHASUM}_${VERSION}/Release/libcurl.dylib dist/sdk/Mac64/
cp buildmac64_${SHASUM}_${VERSION}/Release/libHiveMP.ClientConnect.dylib dist/sdk/Mac64/