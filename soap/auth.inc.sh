#
# Include file to be used by MessageMedia SOAP API example scripts.
#

# If not specified already (eg via environment variables), prompt the user for
# the MessageMedia SOAP API credentials to use.
if [ -z "$MESSAGEMEDIA_USERID" ]; then
    read -p "MessageMedia SOAP API userId: " -r MESSAGEMEDIA_USERID
    unset MESSAGEMEDIA_PASSWORD
fi
if [ -z "$MESSAGEMEDIA_PASSWORD" ]; then
    read -p "MessageMedia SOAP API password: " -r -s MESSAGEMEDIA_PASSWORD
    echo 2>&1
fi
