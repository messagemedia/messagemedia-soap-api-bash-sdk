#!/bin/bash

DIFF=`which colordiff`
if [ -z "$DIFF" ]; then DIFF=`which diff`; fi

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
    OUTPUT=`"$DIFF" "$TEST.xml" "/tmp/soap.$TEST.xml"`
    if [ $? -eq 0 ]; then
        echo -e ' \x1b[32mpassed\x1b[0m'
        PASSED=$(( $PASSED + 1))
    else
        echo -e ' \x1b[31mfailed:\x1b[0m'
        echo "$OUTPUT"
    fi
done
echo "$PASSED of ${#TESTS[@]} tests passed."
