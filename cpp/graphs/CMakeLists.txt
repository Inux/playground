cmake_minimum_required(VERSION 3.12)
project(inuxcore C CXX)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

# we use this to get code coverage
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-arcs -ftest-coverage -std=c11")
endif()

# Mac handle for openssl and libuv
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
include_directories(/usr/local/include)
include_directories(/usr/local/opt/openssl/include)
link_directories(/usr/local/lib)
link_directories(/usr/local/opt/openssl/lib)
link_directories(/usr/local/Cellar/libuv/1.28.0/lib)
endif(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")

add_subdirectory(src)

enable_testing()
add_subdirectory(test)
