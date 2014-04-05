#!/bin/bash
#
# Example shell script for sending SMS messages via MessageMedia's SOAP API.
#
# Run with --help for basic usage.  See the accompanying README.md file for
# detailed usage information.
#

# @todo
#   --scheduled
#   --tag
#   --validaity-period

. "$(dirname $(readlink -f $0))/auth.inc.sh"
. "$(dirname $(readlink -f $0))/functions.inc.sh"

# Some defaults.
ENDPOINT='https://soap.m4u.com.au'
MESSAGE_FORMAT='SMS'
RECIPIENT_ID=0
SEQUENCE_NUMBER=0

# Paths to required commands.
CURL=`which curl`
SED=`which sed`

# Show a basic, standardise usage message.
showUsage() {
    echo -e "\nUsage: "`basename $0`" options message\n" >&2
    exit 128
}

if [ "$1" = '--send-mode' ]; then
    requireArg $1 $#
    requireOneOf $1 $2 dropAll dropAllWithError dropAllWithSuccess normal
    SEND_MODE="$2"
    shift 2
fi

while [ $# -gt 0 ]; do
    HAVE_TRAILING_OPTIONS=true
    SAFE_ARG=`echo "$2" | "$SED" -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'`
    case "$1" in
        -d|--delivery-report)
            if [[ "$2" = 'true' || "$2" = 'false' ]]; then
                DELIVERY_REPORT="$2"
                shift
            else
                DELIVERY_REPORT='true'
            fi
            ;;
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
        -f|--from|--source)
            requireArg $1 $#
            SOURCE="$SAFE_ARG"
            shift
            ;;
        --format)
            requireArg
            requireOneOf "$1" "$2" SMS voice
            shift
            ;;
        --help)
            showUsage
            ;;
        --recipient-id)
            requireArg $1 $#
            RECIPIENT_ID="$SAFE_ARG"
            shift
            ;;
        --send-mode)
            echo -e "\nError: If present, --sendMode must be the first option specified."
            showUsage
            ;;
        -t|--to|--recipient)
            requireArg $1 $#
            RECIPIENTS[$RECIPIENT_ID]="$SAFE_ARG"
            RECIPIENT_ID=$(( $RECIPIENT_ID + 1 ));
            shift
            ;;
        -c|-m|--content|--message)
            requireArg $1 $#
            if [ ${#RECIPIENTS[@]} -eq 0 ]; then
                echo
                echo "Error: No recipient(s) for message '$2'."
                showUsage
            fi
            LF=$'\n'
            MESSAGE="     <ns:message format=\"SMS\" sequenceNumber=\"$SEQUENCE_NUMBER\">$LF      <ns:recipients>$LF"
            for RECIPIENT_ID in "${!RECIPIENTS[@]}"; do
                MESSAGE+="       <ns:recipient uid=\"$RECIPIENT_ID\">${RECIPIENTS[$RECIPIENT_ID]}</ns:recipient>$LF"
            done
            MESSAGE+="      </ns:recipients>$LF"
            if [ -n "$DELIVERY_REPORT" ]; then
                MESSAGE+="<ns:deliverReport>$DELIVERY_REPORT</ns:deliverReport>$LF"
            fi
            MESSAGE+="      <ns:content>$SAFE_ARG</ns:content>$LF     </ns:message>$LF"
            unset HAVE_TRAILING_OPTIONS
            unset RECIPIENTS
            MESSAGES+=( "$MESSAGE" )
            SEQUENCE_NUMBER=$(( $SEQUENCE_NUMBER + 1 ))
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
  <ns:sendMessages>
   <ns:authentication>
    <ns:userId>$MESSAGEMEDIA_USERID</ns:userId>
    <ns:password>$MESSAGEMEDIA_PASSWORD</ns:password>
   </ns:authentication>
   <ns:requestBody>
    <ns:messages"
if [ -n "$SEND_MODE" ]; then
    SOAP_REQUEST="$SOAP_REQUEST sendMode=\"$SEND_MODE\"";
fi
SOAP_REQUEST+=">
"

for MESSAGE in "${MESSAGES[@]}"; do
    SOAP_REQUEST+="$MESSAGE"
done

SOAP_REQUEST+="    </ns:messages>
   </ns:requestBody>
  </ns:sendMessages>
 </env:Body>
</env:Envelope>"

if [ -n "$HAVE_TRAILING_OPTIONS" ]; then
    echo -e "\nError: Found trailing options after the final message to be sent."
    showUsage
fi

# If debugging, log the request.
if [ -n "$DEBUG" ]; then
    echo; echo "$SOAP_REQUEST"; echo
fi

# If not performing a dryrun, carry out the SOAP request.
if [ -z "$DRYRUN" ]; then
    "$CURL" --data-binary "$SOAP_REQUEST" --header "Content-type: text/xml; charset=$CHARSET" "$ENDPOINT"
fi
