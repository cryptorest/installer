#!/bin/sh

CURRENT_DIR="${CURRENT_DIR:=$(cd "$(dirname "$0")" && pwd -P)}"

CRYPTOREST_ENV_FILE="$CURRENT_DIR/../.env"
CRYPTOREST_NGINX_ETC_ENV_FILE="$CURRENT_DIR/../etc/nginx/.env"

if [ ! -f "$CRYPTOREST_ENV_FILE" ]; then
    CRYPTOREST_ENV_FILE="$CURRENT_DIR/../../.env"
    if [ ! -f "$CRYPTOREST_NGINX_ETC_ENV_FILE" ]; then
        CRYPTOREST_NGINX_ETC_ENV_FILE="$CURRENT_DIR/../../etc/nginx/.env"
    fi
fi

. "$CRYPTOREST_ENV_FILE"
. "$CRYPTOREST_NGINX_ETC_ENV_FILE"


CRYPTOREST_DIR="${CRYPTOREST_DIR:=$(cd "$(dirname "$0")"/../ && pwd -P)}"


nginx_init()
{
    local modules='letsencrypt openssl'
    local m_file=''

    for m in $modules; do
        m_file="$CRYPTOREST_DIR/bin/cryptorest-nginx-$m-init"

        if [ -f "$m_file" ]; then
            . "$m_file"
            break
        fi
    done
}


nginx_init
