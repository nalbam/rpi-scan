#!/bin/bash

SHELL_DIR=$(dirname $0)

cd ${SHELL_DIR}/src

pm2 start server.js
