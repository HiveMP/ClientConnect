set(CMAKE_SYSTEM_NAME Linux)

set(CMAKE_C_COMPILER gcc)
set(CMAKE_C_FLAGS -m64)
set(CMAKE_CXX_COMPILER g++)
set(CMAKE_CXX_FLAGS -m64)

set(OPENSSL_INCLUDE_DIR /usr/include/x86_64-linux-gnu)
set(OPENSSL_ROOT_DIR "/usr/lib/x86_64-linux-gnu" CACHE STRING "" FORCE)