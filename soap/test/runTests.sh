#!/bin/bash

if [ $# -gt 0 ]; then
    TESTS=( $@ )
else
    TESTS=( `find . -name '*.sh' ! -name 'runTests.sh'` )
fi

for TEST in "${TESTS[@]}"; do
    TEST=`basename "$TEST" .sh`
    echo -n "Test: $TEST"
    "./$TEST.sh" > "/tmp/soap.$TEST.xml"
    diff "$TEST.xml" "/tmp/soap.$TEST.xml"
    echo
done
