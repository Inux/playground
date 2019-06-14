# Build Library & Executable

## Set version used by version.h
set (inuxcore_VERSION_MAJOR 0)
set (inuxcore_VERSION_MINOR 1)

## Create version file
configure_file (
  "${PROJECT_SOURCE_DIR}/src/version.h.in"
  "${PROJECT_BINARY_DIR}/version.h"
)
include_directories("${PROJECT_BINARY_DIR}")


## Build inuxcore Library
add_library(inuxcorelib SHARED "")
add_subdirectory(lib/graphs)
target_link_libraries(inuxcorelib)

# uws
add_compile_definitions(LIBUS_USE_LIBUV)
add_compile_definitions(LIBUS_NO_SSL)
add_subdirectory(lib/vendor)

## Build Executable
add_executable(inuxcore main.cpp)
target_link_libraries(inuxcore inuxcorelib uws)
