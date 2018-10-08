#!/bin/bash

SHELL_DIR=$(dirname $0)

CMD=$1

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
    KEY=$1
    VAL=$2

    if [ -z ${VAL} ]; then
        _read "${KEY} [${VAL}] : "

        if [ ! -z ${ANSWER} ]; then
            echo "export ${KEY}=${VAL}" >> ${CONFIG}
        fi
    fi

    _config_save
}

_config_save() {
    echo "# wifi-spi config" > ${CONFIG}
    echo "export LAMBDA_ID=${LAMBDA_ID}" >> ${CONFIG}
    echo "export LAMBDA_API=${LAMBDA_API}" >> ${CONFIG}
    . ${CONFIG}
}

if [ -z ${LAMBDA_API} ]; then
    _read "LAMBDA_API [${LAMBDA_API}] : "

    if [ ! -z ${ANSWER} ]; then
        LAMBDA_API="${ANSWER}"
        echo "export LAMBDA_API=${LAMBDA_API}" > ${CONFIG}
    fi
fi

_result "LAMBDA_API: ${LAMBDA_API}"
export LAMBDA_API="${LAMBDA_API}"

# pushd ${SHELL_DIR}
# git pull
# popd

# pushd ${SHELL_DIR}/src
# npm run build
# popd

_stop

if [ -z ${CMD} ] || [ "${CMD}" == "start" ]; then
    _config_read "LAMBDA_ID" "${LAMBDA_ID}"
    _config_read "LAMBDA_API" "${LAMBDA_API}"

    _start
fi
