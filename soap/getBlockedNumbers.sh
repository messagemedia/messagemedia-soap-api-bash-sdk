#!/bin/bash
#
# Example shell script for retrieving blocked numbers via MessageMedia's SOAP API.
#
# Run with --help for basic usage.  See the accompanying README.md file for
# detailed usage information.
#

. "$(dirname $(readlink -f $0))/auth.inc.sh"
. "$(dirname $(readlink -f $0))/functions.inc.sh"

# Some defaults.
ENDPOINT='https://soap.m4u.com.au'

# Paths to required commands.
CURL=`which curl`
SED=`which sed`

# Show a basic, standardise usage message.
showUsage() {
    echo -e "\nUsage: "`basename $0`" [--debug] [--dryrun] [--max-recipients n]\n" >&2
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
        --help)
            showUsage
            ;;
        --max-recipients|--maximum-recipients)
            requireArg $1 $#
            MAXIMUM_RECIPIENTS="$SAFE_ARG"
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
  <ns:getBlockedNumbers>
   <ns:authentication>
    <ns:userId>$MESSAGEMEDIA_USERID</ns:userId>
    <ns:password>$MESSAGEMEDIA_PASSWORD</ns:password>
   </ns:authentication>
   <ns:requestBody>"
if [ -n "$MAXIMUM_RECIPIENTS" ]; then
    SOAP_REQUEST="$SOAP_REQUEST
    <ns:maximumRecipients>$MAXIMUM_RECIPIENTS</ns:maximumRecipients>"
fi
SOAP_REQUEST="$SOAP_REQUEST
   </ns:requestBody>
  </ns:getBlockedNumbers>
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
