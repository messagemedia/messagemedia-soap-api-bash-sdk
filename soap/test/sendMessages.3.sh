MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password \
    $(dirname $(readlink --canonicalize "$0"))/../sendMessages.sh \
    --debug --dryrun --scheduled '2014-05-14T12:30:00' \
    --to 61412345678 --message 'Scheduled test message.'
