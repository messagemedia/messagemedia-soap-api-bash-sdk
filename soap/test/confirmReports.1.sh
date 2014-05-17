MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password \
    $(dirname $(readlink --canonicalize "$0"))/../confirmReports.sh \
    --debug --dryrun 123 456 789
