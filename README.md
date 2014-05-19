messagemedia-bash
==================

Sample Bash code for accessing MessageMedia APIs.

### SOAP

The [soap](soap) directory contains sample code for accessing MessageMedia's
[SOAP API](http://files.message-media.com.au/docs/MessageMedia_Messaging_Web_Service.pdf).

See the [README.md](soap/README.md) file in [soap](soap) directory for details.

### Cygwin on Windows
Please ensure Curl is installed and you may need to modify the EOL behaviour in Cygwin
by setting the following in your .bash_profile:

```bash
export SHELLOPTS
set -o igncr
```