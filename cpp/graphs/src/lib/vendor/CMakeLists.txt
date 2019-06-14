find_package(OpenSSL)

file(GLOB_RECURSE SRC_UWEBSOCKETS "${CMAKE_CURRENT_SOURCE_DIR}/uWebSockets/src/*.hpp")
file(GLOB_RECURSE SRC_USOCKETS "${CMAKE_CURRENT_SOURCE_DIR}/uWebSockets/uSockets/src/*.c")

add_library(uws SHARED ${SRC_UWEBSOCKETS} ${SRC_USOCKETS})

target_include_directories(
    uws
    PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/uWebSockets/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/uWebSockets/src/f2"
    "${CMAKE_CURRENT_SOURCE_DIR}/uWebSockets/uSockets/src"
)

target_compile_features(uws PRIVATE cxx_std_11)

target_link_libraries(
    uws
    PUBLIC
    uv
    ssl
    crypto
    z
)
