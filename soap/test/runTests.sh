#!/bin/bash

if [ $# -gt 0 ]; then
    TESTS=( $@ )
else
    TESTS=( `find . -name '*.sh' ! -name 'runTests.sh'` )
fi

PASSED=0
for TEST in "${TESTS[@]}"; do
    TEST=`basename "$TEST" .sh`
    echo -n "Test: $TEST"
    "./$TEST.sh" > "/tmp/soap.$TEST.xml"
    OUTPUT=`diff "$TEST.xml" "/tmp/soap.$TEST.xml"`
    if [ $? -eq 0 ]; then
        echo ' passed'
        PASSED=$(( $PASSED + 1))
    else
        echo ' failed'
        echo "$OUTPUT"
    fi
done
echo "$PASSED of ${#TESTS[@]} tests passed."
