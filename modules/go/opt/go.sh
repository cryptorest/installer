#!/bin/sh

CURRENT_DIR="${CURRENT_DIR:=$(cd "$(dirname "$0")" && pwd -P)}"

CRYPTOREST_ENV_FILE="$CURRENT_DIR/../.env"
CRYPTOREST_GO_ETC_ENV_FILE="$CURRENT_DIR/../etc/go/.env"

if [ ! -f "$CRYPTOREST_ENV_FILE" ]; then
    CRYPTOREST_ENV_FILE="$CURRENT_DIR/../../.env"
    if [ ! -f "$CRYPTOREST_GO_ETC_ENV_FILE" ]; then
        CRYPTOREST_GO_ETC_ENV_FILE="$CURRENT_DIR/../../etc/go/.env"
    fi
fi

. "$CRYPTOREST_GO_ETC_ENV_FILE"

CRYPTOREST_DIR="${CRYPTOREST_DIR:=$(cd $(dirname $0)/../ && pwd -P)}"


"$CRYPTOREST_DIR/bin/go" $@
