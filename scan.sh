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
MAIN_LIST=$(mktemp /tmp/wifi-spi-main-list.XXXXXX)
SCAN_LIST=$(mktemp /tmp/wifi-spi-scan-list.XXXXXX)

# main list
curl -sL ${LAMBDA_API} | jq -r '.[] | "\(.mac) \(.checked)"' > ${MAIN_LIST}

# scan list
sudo arp-scan -l | grep -E "([0-9]{1,3}\\.){3}[0-9]{1,3}" > ${SCAN_LIST}

while read VAR; do
    ARR=($(echo $VAR))

    IP="${ARR[0]}"
    MAC="${ARR[1]}"
    DESC="${ARR[0]}"

    CHECKED=$(cat ${MAIN_LIST} | grep ${MAC} | awk {'print $1'})

    # POST
    if [ -z ${CHECKED} ] || [ "${CHECKED}" == "true" ]; then
        echo "${VAR}"

        # DATA="{\"ip\":\"${IP}\",\"mac\":\"${MAC}\",\"desc\":\"${DESC}\"}"
        # curl --header "Content-Type: application/json" \
        #      --request POST --data "${DATA}" \
        #      -sL ${LAMBDA_API}
    fi
done < ${SCAN_LIST}
