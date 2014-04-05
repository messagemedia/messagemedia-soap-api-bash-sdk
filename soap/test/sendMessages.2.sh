MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password \
    ../sendMessages.sh --send-mode dropAllWithSuccess --debug --dryrun \
    --to 61412345678 --message 'Test message 1.' \
    --delivery-report --from 614098765432 --format voice \
    --recipient-id 4321 --to 61412345678 --to 61423456789 \
    --recipient-id 1000 --to 61434567890 --tag tag1 value1 --tag tag2 value2 \
    --validity-period 234 --message 'Test message 2.' \
    --to 61412345678 --message 'Test message 3.'
