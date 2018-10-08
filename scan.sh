#!/bin/bash

SHELL_DIR=$(dirname $0)

CONFIG=~/.wifi-spi
touch ${CONFIG}
. ${CONFIG}

if [ -z ${LAMBDA_KEY} ] || [ "${LAMBDA_KEY}" == "" ]; then
    exit 1
fi
if [ -z ${LAMBDA_API} ] || [ "${LAMBDA_API}" == "" ]; then
    exit 1
fi

# tmp
MAIN_LIST=/tmp/wifi-spi-main-list
SCAN_LIST=/tmp/wifi-spi-scan-list

# main list
curl -sL ${LAMBDA_API} | jq -r '.[] | "\(.mac) \(.checked)"' > ${MAIN_LIST}

# scan list
sudo arp-scan -l | grep -E "([0-9]{1,3}\\.){3}[0-9]{1,3}" > ${SCAN_LIST}

while read VAR; do
    ARR=($(echo $VAR))

    MAC="${ARR[1]}"

    CHECKED=$(cat ${MAIN_LIST} | grep ${MAC} | awk {'print $1'})

    # POST
    if [ -z ${CHECKED} ] || [ "${CHECKED}" == "true" ]; then
        echo "${VAR}"
    fi
done < ${SCAN_LIST}
