MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password \
    $(dirname $(readlink --canonicalize "$0"))/../blockNumbers.sh \
    --debug --dryrun \
    --recipient-id 456 61412345678 \
    --recipient-id 123 61498765432
