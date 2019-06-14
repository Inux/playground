target_sources(
    inuxcorelib
    PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}/node.cpp
)

target_include_directories(
    inuxcorelib
    PUBLIC
    ${CMAKE_CURRENT_LIST_DIR}
)
