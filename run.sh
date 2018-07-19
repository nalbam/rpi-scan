#!/bin/bash

SHELL_DIR=$(dirname $0)

cd ${SHELL_DIR}

git pull

cd ${SHELL_DIR}/src

npm install

node server.js &
