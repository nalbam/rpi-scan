#!/bin/bash

SHELL_DIR=$(dirname $0)

CONFIG=~/.wifi-spi
touch ${CONFIG}
. ${CONFIG}

command -v tput > /dev/null || TPUT=false

_echo() {
    if [ -z ${TPUT} ] && [ ! -z $2 ]; then
        echo -e "$(tput setaf $2)$1$(tput sgr0)"
    else
        echo -e "$1"
    fi
}

_read() {
    if [ -z ${TPUT} ]; then
        read -p "$(tput setaf 6)$1$(tput sgr0)" ANSWER
    else
        read -p "$1" ANSWER
    fi
}

_result() {
    _echo "# $@" 4
}

_command() {
    _echo "$ $@" 3
}

_success() {
    _echo "+ $@" 2
    exit 0
}

_error() {
    _echo "- $@" 1
    exit 1
}

_config_check() {
    KEY=$1
    VAL=$2

    if [ -z ${VAL} ] || [ "${VAL}" == "" ]; then
        _error "empty ${KEY}"
    fi
}

_config_check "LAMBDA_ID" "${LAMBDA_ID}"
_config_check "LAMBDA_API" "${LAMBDA_API}"

MAC_LIST=$(mktemp /tmp/wifi-spi-mac-list.XXXXXX)

# mac list
curl -sL ${LAMBDA_API} | jq -r '.[] | "\(.mac) \(.checked)"' > ${MAC_LIST}
