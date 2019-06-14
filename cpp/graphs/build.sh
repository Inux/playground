#!/bin/zsh

# Install before:
# - gtest (GoogleTest - https://stackoverflow.com/questions/15852631/how-to-install-gtest-on-mac-os-x-with-homebrew/15872801)

BUILD_DIR="build"

function setup {
    if [ ! -d "$BUILD_DIR" ]; then
    ./install.sh
    fi
}

function build {
    (cd build && make)
}

function runTests {
    ./build/test/tests
}

# Main Flow

setup
build
runTests
