set(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_C_COMPILER gcc)
set(CMAKE_C_FLAGS -m32)
set(CMAKE_CXX_COMPILER g++)
set(CMAKE_CXX_FLAGS -m32)

set(OPENSSL_INCLUDE_DIR /usr/include/i386-linux-gnu)
set(OPENSSL_ROOT_DIR "/usr/lib/i386-linux-gnu" CACHE STRING "" FORCE)