# SOAP

Sample Bash code for accessing MessageMedia's SOAP API.

## Requirements

These examples have very few requirements:
* Bash
* cURL
* sed

## Authentication

In the interest of security, these scripts do not accept credentials via
command line options, as those would be visible in process lists.  Instead
credentials can be provided via the following environment variables:
* `MESSAGEMEDIA_USERID`
* `MESSAGEMEDIA_PASSWORD`

Of course, these can be added to your shell startup environment.  And if
supported by your shell, can be specified from the command line like:

```
MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password ./checkUser.sh
```

If the credentials are not provided via the environment, then the scripts
will prompt for them instead.
