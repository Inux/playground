#!/bin/bash

#cmds using during build
cmds=(
    '(cd multithreading; ./build.sh;)'
    '(cd generics; ./build.sh;)'
    '(cd lists; ./build.sh;)'
)

#makes the actual build
doBuild () {
    for cmd in "${cmds[@]}"
    do
        echo 'Build: '$cmd
        eval $cmd
    done
    echo 'Build done. Successful'
}

#timing build
time doBuild