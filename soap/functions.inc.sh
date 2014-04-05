#
# Include functions to be used by MessageMedia SOAP API example scripts.
#

# Require a command line argument be present.
# @param  $1  Option name.
# @param  $2  Number of remaining command line options.
requireArg() {
    if [ "$2" -lt 2 ]; then
        echo -e "\nError: Missing required parameter for option '$1'." >&2
        showUsage
    fi
}

# Require a command line argument be one of a set of values.
# @param  $1  Option name.
# @param  $2  Argument value.
# @param  $@  Allows options.
requireOneOf() {
    OPTION_NAME="$1"
    OPTION_ARG="$2"
    shift 2
    while [ $# -gt 0 ]; do
        if [ "$OPTION_ARG" = $1 ]; then return 0; fi
        shift
    done
    echo -e "\nError: Option '$OPTION_NAME' does not accept the parameter '$OPTION_ARG'." >&2
    return 1
}
