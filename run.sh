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

if [ -z ${LAMBDA_API} ]; then
    _read "LAMBDA_API [${LAMBDA_API}] : "

    if [ ! -z ${ANSWER} ]; then
        LAMBDA_API="${ANSWER}"
        echo "export LAMBDA_API=${LAMBDA_API}" > ${CONFIG}
    fi
fi

export LAMBDA_API="${LAMBDA_API}"

# pushd ${SHELL_DIR}
# git pull
# popd

# pushd ${SHELL_DIR}/src
# npm run build
# popd

cd ${SHELL_DIR}/src/
rm -rf nohup.out
nohup node server.js &
