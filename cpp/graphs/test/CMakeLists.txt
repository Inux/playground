# Tests
find_package(GTest REQUIRED)
include_directories(${GTEST_INCLUDE_DIRS})

add_executable (
    tests
    test_main.cpp
    graph/node_test.cpp
)

target_link_libraries(
    tests
    ${GTEST_BOTH_LIBRARIES}
    inuxcorelib
)

add_test(
  NAME
    test
  COMMAND
    ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}/test/tests
)
