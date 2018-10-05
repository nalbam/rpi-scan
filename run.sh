#!/bin/bash

SHELL_DIR=$(dirname $0)

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

CONFIG=~/.wifi-spi
touch ${CONFIG}
. ${CONFIG}

if [ -z ${LAMBDA_HOST} ]; then
    _read "LAMBDA_HOST [${LAMBDA_HOST}] : "

    if [ ! -z ${ANSWER} ]; then
        LAMBDA_HOST="${ANSWER}"
        echo "export LAMBDA_HOST=${LAMBDA_HOST}" > ${CONFIG}
    fi
fi

export LAMBDA_HOST="${LAMBDA_HOST}"

# pushd ${SHELL_DIR}
# git pull
# popd

# pushd ${SHELL_DIR}/src
# npm run build
# popd

cd ${SHELL_DIR}/src/
nohup node server.js &
