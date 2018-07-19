#!/bin/bash

SHELL_DIR=$(dirname $0)

cd ${SHELL_DIR}/src

node server.js &
