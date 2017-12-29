#!/bin/sh

CURRENT_DIR="${CURRENT_DIR:=$(cd $(dirname $0) && pwd -P)}"

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


CRYPTOREST_DIR="${CRYPTOREST_DIR:=$(cd $(dirname $0)/../ && pwd -P)}"
CRYPTOREST_PUBLIC_KEY_PINS=''

CRYPTOREST_WWW_DIR="$CRYPTOREST_DIR/www"
CRYPTOREST_ETC_DIR="$CRYPTOREST_DIR/etc"
CRYPTOREST_ETC_SSL_DIR="$CRYPTOREST_ETC_DIR/ssl"
CRYPTOREST_OPT_DIR="$CRYPTOREST_DIR/opt"

CRYPTOREST_OPENSSL_ETC_DIR="$CRYPTOREST_ETC_DIR/openssl"
CRYPTOREST_OPENSSL_OPT_DIR="$CRYPTOREST_OPT_DIR/openssl"

CRYPTOREST_NGINX_VAR_LOG_DIR="$CRYPTOREST_DIR/var/log/nginx"
CRYPTOREST_NGINX_ETC_DIR="$CRYPTOREST_ETC_DIR/nginx"
CRYPTOREST_NGINX_OPT_DIR="$CRYPTOREST_OPT_DIR/nginx"


openssl_init_prepare()
{
    mkdir -p "$CRYPTOREST_SSL_DOMAIN_DIR" && \
    chmod 700 "$CRYPTOREST_SSL_DOMAIN_DIR" && \
    mkdir -p "$CRYPTOREST_WWW_DOMAIN_DIR" && \
    chmod 700 "$CRYPTOREST_WWW_DOMAIN_DIR" && \
    mkdir -p "$CRYPTOREST_NGINX_LOG_DOMAIN_DIR" && \
    chmod 700 "$CRYPTOREST_NGINX_LOG_DOMAIN_DIR" && \
    openssl_session_ticket_key_define && \
    #openssl_ecdsa_define && \
    openssl_hd_param_define && \
    openssl_ciphers_define && \
    #openssl_public_key_pins_define && \
    nginx -v && \
    nginx_configs_define
}


openssl_init_run()
{
    local domains_dir="$CRYPTOREST_ETC_DIR/.domains"

    . "$CRYPTOREST_NGINX_OPT_DIR/config-define.sh"

    for d in $(ls "$domains_dir"); do
        if [ -f "$domains_dir/$d" ]; then
            . "$domains_dir/$d"

            CRYPTOREST_SSL_DOMAIN_DIR="$CRYPTOREST_ETC_SSL_DIR/$CRYPTOREST_LIB_DOMAIN"
            CRYPTOREST_NGINX_LOG_DOMAIN_DIR="$CRYPTOREST_NGINX_VAR_LOG_DIR/$CRYPTOREST_LIB_DOMAIN"
            CRYPTOREST_WWW_DOMAIN_DIR="$CRYPTOREST_WWW_DIR/$d"

            . "$CRYPTOREST_OPENSSL_OPT_DIR/certs-define.sh"

            openssl_init_prepare
        fi
    done
}


openssl_init_run
