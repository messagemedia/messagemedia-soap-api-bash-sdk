MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password \
    $(dirname $(readlink --canonicalize "$0"))/../blockNumbers.sh \
    --debug --dryrun 61412345678 61498765432
