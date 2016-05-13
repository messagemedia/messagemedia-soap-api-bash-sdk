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

#
# Example shell script for checking for replies via MessageMedia's SOAP API.
#
# Usage: checkReplies.sh [--debug] [--dryrun] [--max-replies n]
#
# Run with --help for additional information, or see the accompanying
# README.md file.
#

. "$(dirname "$(readlink -f $0)")/auth.inc.sh"
. "$(dirname "$(readlink -f $0)")/functions.inc.sh"

# Some defaults.
ENDPOINT='https://soap.m4u.com.au'

# Paths to required commands.
CURL=`which curl`
SED=`which sed`

# Show a basic, standardise usage message.
showUsage() {
    echo -e "\nUsage: "`basename $0`" [--debug] [--dryrun] [--max-replies n]\n" >&2
    exit 128
}

while [ $# -gt 0 ]; do
    SAFE_ARG=`echo "$2" | "$SED" -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'`
    case "$1" in
        --debug)
            DEBUG=true
            ;;
        --dryrun|--dry-run)
            DRYRUN=true
            ;;
        --endpoint)
            requireArg $1 $#
            ENDPOINT="$2"
            shift
            ;;
        --help)
            showUsage
            ;;
        --max-replies|--maximum-replies)
            requireArg $1 $#
            MAXIMUM_REPLIES="$SAFE_ARG"
            shift
            ;;
        *)
            echo -e "\nError: Unknown option '$1'." >&2
            showUsage
            ;;
    esac
    shift
done

CHARSET=`echo ${LANG} | ${SED} 's/^.*\.//' | tr 'A-Z' 'a-z-'`

SOAP_REQUEST="<?xml version=\"1.0\" encoding=\"$CHARSET\"?>
<env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"http://xml.m4u.com.au/2009\">
 <env:Body>
  <ns:checkReplies>
   <ns:authentication>
    <ns:userId>$MESSAGEMEDIA_USERID</ns:userId>
    <ns:password>$MESSAGEMEDIA_PASSWORD</ns:password>
   </ns:authentication>
   <ns:requestBody>"
if [ -n "$MAXIMUM_REPLIES" ]; then
    SOAP_REQUEST="$SOAP_REQUEST
    <ns:maximumReplies>$MAXIMUM_REPLIES</ns:maximumReplies>"
fi
SOAP_REQUEST="$SOAP_REQUEST
   </ns:requestBody>
  </ns:checkReplies>
 </env:Body>
</env:Envelope>"

# If debugging, log the request.
if [ -n "$DEBUG" ]; then
    echo; echo "$SOAP_REQUEST"; echo
fi

# If not performing a dryrun, carry out the SOAP request.
if [ -z "$DRYRUN" ]; then
    "$CURL" --data-binary "$SOAP_REQUEST" --header "Content-type: text/xml; charset=$CHARSET" "$ENDPOINT"
fi
