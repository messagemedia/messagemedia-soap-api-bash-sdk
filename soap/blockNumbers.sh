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
# Example shell script for blocking numbers via MessageMedia's SOAP API.
#
# Usage: blockNumbers.sh [options] phone1 [phone2 [...]]
#
# Run with --help for additional information, or see the accompanying
# README.md file.
#

. "$(dirname "$(readlink -f $0)")/auth.inc.sh"
. "$(dirname "$(readlink -f $0)")/functions.inc.sh"

# Some defaults.
ENDPOINT='https://soap.m4u.com.au'
RECIPIENT_ID=0

# Paths to required commands.
CURL=`which curl`
SED=`which sed`

# Show a basic, standardise usage message.
showUsage() {
    echo -e "\nUsage: "`basename $0`" [options] phone1 [phone2 [...]]\n" >&2
    exit 128
}

while [ $# -gt 0 ]; do
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
        --recipient-id)
            requireArg $1 $#
            RECIPIENT_ID=`echo "$2" | "$SED" -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'`
            shift
            ;;
        *)
            RECIPIENT=`echo "$1" | "$SED" -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'`
            RECIPIENTS[$RECIPIENT_ID]="$RECIPIENT"
            RECIPIENT_ID=$(( $RECIPIENT_ID + 1 ))
            ;;
    esac
    shift
done

# Ensure we have at least one recipient to block.
if [ ${#RECIPIENTS[@]} -eq 0 ]; then
    showUsage
fi

CHARSET=`echo ${LANG} | ${SED} 's/^.*\.//' | tr 'A-Z' 'a-z-'`

SOAP_REQUEST="<?xml version=\"1.0\" encoding=\"$CHARSET\"?>
<env:Envelope xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"http://xml.m4u.com.au/2009\">
 <env:Body>
  <ns:blockNumbers>
   <ns:authentication>
    <ns:userId>$MESSAGEMEDIA_USERID</ns:userId>
    <ns:password>$MESSAGEMEDIA_PASSWORD</ns:password>
   </ns:authentication>
   <ns:requestBody>
    <ns:recipients>"

for RECIPIENT_ID in "${!RECIPIENTS[@]}"; do
    SOAP_REQUEST="$SOAP_REQUEST
     <ns:recipient uid=\"$RECIPIENT_ID\">${RECIPIENTS[$RECIPIENT_ID]}</ns:recipient>"
done

SOAP_REQUEST="$SOAP_REQUEST
    </ns:recipients>
   </ns:requestBody>
  </ns:blockNumbers>
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
