MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password \
    $(dirname $(readlink --canonicalize "$0"))/../sendMessages.sh \
    --debug --dryrun --to 61412345678 --message 'Test message.'
