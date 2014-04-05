#!/bin/bash
#
# Example shell script for sending SMS messages via MessageMedia's SOAP API.
#
# Run with --help for basic usage.  See the accompanying README.md file for
# detailed usage information.
#

# @todo
#   --first-recipient-id
#   --recipient
#   --scheduled
#   --tag
#   --validaity-period
#   --content
#   --endpoint

# Some defaults.
ENDPOINT='https://soap.m4u.com.au'
MESSAGE_FORMAT='SMS'
RECIPIENT_ID=0
SEQUENCE_NUMBER=0

# Paths to required commands.
CURL=`which curl`
SED=`which sed`
LF=$'\n'

# Show a basic, standardise usage message.
showUsage() {
    echo -e "\nUsage: "`basename $0`" options message\n" >&2
    exit 128
}

# Require a command line argument be present.
# @param  $1  Option name.
# @param  $2  Number of remaining command line options.
requireArg() {
    if [ "$2" -lt 2 ]; then
        echo -e "\nError: Missing required parameter for option '$1'." >&2
        showUsage
    fi
}

# Require a command line argument be one of a set of values.
# @param  $1  Option name.
# @param  $2  Argument value.
# @param  $@  Allows options.
requireOneOf() {
    OPTION_NAME="$1"
    OPTION_ARG="$2"
    shift 2
    while [ $# -gt 0 ]; do
        if [ "$OPTION_ARG" = $1 ]; then return 0; fi
        shift
    done
    echo -e "\nError: Option '$OPTION_NAME' does not accept the parameter '$OPTION_ARG'." >&2
    return 1
}

# TODO: Prompt for these?
if [ -z "$MESSAGEMEDIA_USERID" ]; then
    echo -e "\nError: MESSAGEMEDIA_USERID environment variable not set." >&2
    showUsage
elif [ -z "$MESSAGEMEDIA_PASSWORD" ]; then
    echo -e "\nError: MESSAGEMEDIA_PASSWORD environment variable not set." >&2
    showUsage
fi

if [ "$1" = '--send-mode' ]; then
    requireArg $1 $#
    requireOneOf $1 $2 dropAll dropAllWithError dropAllWithSuccess normal
    SEND_MODE="$2"
    shift 2
fi

CHARSET=`echo ${LANG} | ${SED} 's/^.*\.//' | tr 'A-Z' 'a-z-'`

SOAP_REQUEST="<?xml version=\"1.0\" encoding=\"$CHARSET\"?>
<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ns=\"http://xml.m4u.com.au/2009\">
 <soapenv:Body>
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
SOAP_REQUEST="$SOAP_REQUEST>"

while [ $# -gt 0 ]; do
    HAVE_TRAILING_OPTIONS=true
    SAFE_ARG=`echo "$2" | "$SED" -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'`
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
        --send-mode)
            echo -e "\nError: If present, --sendMode must be the first option specified."
            showUsage
            ;;
        -t|--to|--recipient)
            requireArg $1 $#
            RECIPIENTS="$RECIPIENTS       <ns:recipient uid=\"$RECIPIENT_ID\">$SAFE_ARG</ns:recipient>$LF"
            RECIPIENT_ID=$(( $RECIPIENT_ID + 1 ));
            shift
            ;;
        -c|-m|--content|--message)
            requireArg $1 $#
            SOAP_REQUEST="$SOAP_REQUEST$LF     <ns:message format=\"SMS\" sequenceNumber=\"$SEQUENCE_NUMBER\">"
            SOAP_REQUEST="$SOAP_REQUEST$LF      <ns:recipients>$LF$RECIPIENTS      </ns:recipients>"
            if [ -n "$DELIVERY_REPORT" ]; then
                SOAP_REQUEST=$"$SOAP_REQUEST$LF      <ns:deliverReport>$DELIVERY_REPORT</ns:deliverReport>"
            fi
            SOAP_REQUEST=$"$SOAP_REQUEST$LF      <ns:content>$SAFE_ARG</ns:content>$LF     </ns:message>"
            HAVE_TRAILING_OPTIONS=''
            RECIPIENTS=''
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

SOAP_REQUEST="$SOAP_REQUEST
    </ns:messages>
   </ns:requestBody>
  </ns:sendMessages>
 </soapenv:Body>
</soapenv:Envelope>"

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
