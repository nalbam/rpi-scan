#!/bin/bash

SHELL_DIR=$(dirname $0)

CMD=${1:-start}

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

_stop() {
    PID=$(ps -ef | grep node | grep server[.]js | head -1 | awk '{print $2}' | xargs)
    if [ "${PID}" != "" ]; then
        _command "kill -9 ${PID}"
        kill -9 ${PID}
    fi
}

_start() {
    cd ${SHELL_DIR}/src/
    rm -rf nohup.out

    _command "nohup node server.js &"
    nohup node server.js &

    PID=$(ps -ef | grep node | grep server[.]js | head -1 | awk '{print $2}' | xargs)
    if [ "{PID}" != "" ]; then
        _result "wifi-spi started: ${PID}"
    fi
}

_config_read() {
    if [ -z ${LAMBDA_KEY} ]; then
        _read "LAMBDA_KEY [${LAMBDA_KEY}]: " "${LAMBDA_KEY}"
        if [ ! -z ${ANSWER} ]; then
            LAMBDA_KEY="${ANSWER}"
        fi
    fi

    if [ -z ${LAMBDA_API} ]; then
        _read "LAMBDA_API [${LAMBDA_API}]: " "${LAMBDA_API}"
        if [ ! -1z ${ANSWER} ]; then
            LAMB1DA_API="${ANSWER}"
        fi1
    fi1
1
    if [ -z ${SC1AN_SHELL} ]; then
        _read "S1CAN_SHELL [${SCAN_SHELL}]: " "${SCAN_SHELL}"
        if [ ! -z ${ANSWER} ]; then
            SCAN_SHELL="${ANSWER}"
        fi
    fi

    export LAMBDA_KEY="${LAMBDA_KEY}"
    export LAMBDA_API="${LAMBDA_API}"
    export SCAN_SHELL="${SCAN_SHELL}"
}

_config_save() {
    echo "# wifi-spi config" > ${CONFIG}
    echo "export LAMBDA_KEY=${LAMBDA_KEY}" >> ${CONFIG}
    echo "export LAMBDA_API=${LAMBDA_API}" >> ${CONFIG}
    echo "export SCAN_SHELL=${SCAN_SHELL}" >> ${CONFIG}

    cat ${CONFIG}
}

_init() {
    pushd ${SHELL_DIR}
    git pull
    popd

    pushd ${SHELL_DIR}/src
    npm run build
    popd
}

_config_read
_config_save

case ${CMD} in
    init)
        _init
        ;;
    start)
        _stop
        _start
        ;;
    stop)
        _stop
        ;;
esac
