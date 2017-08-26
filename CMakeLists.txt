cmake_minimum_required(VERSION 3.8)
project(HiveMP.ClientConnect)

set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Pretend that we have Perl so that curl will build, but we don't actually need it
set (Perl_FOUND YES)
set (PERL_EXECUTABLE "perl")

# Tweak curl settings
set (ENABLE_MANUAL OFF)
set (HTTP_ONLY ON)
set (CURL_STATICLIB OFF)
set (BUILD_TESTING OFF)
if(WIN32)
  set (CMAKE_USE_WINSSL ON)
endif()

add_subdirectory(curl)
add_subdirectory(HiveMP.ClientConnect)
add_subdirectory(HiveMP.SteamTest)