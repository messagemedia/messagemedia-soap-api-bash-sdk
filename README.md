# MessageMedia Bash SDK
This library provides a simple interface for sending and receiving messages using the [MessageMedia SOAP API](http://www.messagemedia.com.au/wp-content/uploads/2013/05/MessageMedia_Messaging_Web_Service.pdf?eacfbb).

If you have any issue using this sample code, or would like to report a defect, you could [create a new Issue](https://github.com/messagemedia/messagemedia-bash/issues/new) in Github or [Contact us](http://www.messagemedia.com.au/contact-us).

## Installation
### Requirements
* [Bash]
* [curl] 7.2+

#### Cygwin on Windows
Please ensure [curl] is installed and you may need to modify the EOL behaviour
in Cygwin by setting the following in your `.bash_profile`:

```bash
export SHELLOPTS
set -o igncr
```

[Bash]: http://www.gnu.org/software/bash/ "GNU Bash"
[curl]: http://curl.haxx.se/ "curl and libcurl"

## Usage
### Authentication
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

### Common Command Line Options
The following command line options are common to all of these sample scripts:

| Options      | Arguments | Description |
|--------------|:---------:|-------------|
| `--debug`    |           | Enables debug information, such as printing the content of the SOAP request to be sent. |
| `--dryrun`   |           | Do everything up to, but not including, sending the actual request. |
| `--endpoint` | _URL_     | Defaults to `https://soap.m4u.com.au`. |
| `--help`     |           | Show some usage information. |

### checkUser
checkUser is one of the most basic API requests.

Exmaple using `checkUser.sh` to check authentication, credits, etc:
```
$ ./checkUser.sh
<?xml version="1.0" encoding="utf-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Body><checkUserResponse xmlns="http://xml.m4u.com.au/2009">
  <result>
    <accountDetails type="daily" creditLimit="500" creditRemaining="499"/>
  </result>
</checkUserResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>
```

Example using `checkUser.sh` to generate sample checkUser request, but not actually send it:
```
$ MESSAGEMEDIA_USERID=my-user-id MESSAGEMEDIA_PASSWORD=my-password ./checkUser.sh --debug --dryrun

<?xml version="1.0" encoding="utf-8"?>
<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://xml.m4u.com.au/2009">
 <env:Body>
  <ns:checkUser>
   <ns:authentication>
    <ns:userId>my-user-id</ns:userId>
    <ns:password>my-password</ns:password>
   </ns:authentication>
  </ns:checkUser>
 </env:Body>
</env:Envelope>
```

## Contributing
We welcome contributions from our users. Contributing is easy:

  1.  Fork this repo
  2.  Create your feature branch (`git checkout -b my-new-feature`)
  3.  Commit your changes (`git commit -am 'Add some feature'`)
  4.  Push to the branch (`git push origin my-new-feature`)
  5.  Create a Pull Request
