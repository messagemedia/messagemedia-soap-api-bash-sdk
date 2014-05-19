messagemedia-bash
==================

Sample Bash code for accessing MessageMedia APIs.

### SOAP

The [soap](soap) directory contains sample code for accessing MessageMedia's
[SOAP API](http://files.message-media.com.au/docs/MessageMedia_Messaging_Web_Service.pdf).

See the [README.md](soap/README.md) file in [soap](soap) directory for details.

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
