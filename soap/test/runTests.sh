#!/bin/bash
#
# Copyright 2014 MessageMedia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
