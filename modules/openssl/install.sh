#!/bin/sh

CRYPTOREST_OPENSSL_OPT_DIR="$CRYPTOREST_OPT_DIR/openssl"
CRYPTOREST_OPENSSL_ETC_DIR="$CRYPTOREST_ETC_DIR/openssl"
CRYPTOREST_OPENSSL_TITLE='OpenSSL'


letsencrypt_prepare()
{
    rm -rf "$CRYPTOREST_OPENSSL_OPT_DIR" && \
    rm -rf "$CRYPTOREST_OPENSSL_ETC_DIR/"
}

letsencrypt_install()
{
    mkdir -p "$CRYPTOREST_OPENSSL_OPT_DIR" && \
    chmod 700 "$CRYPTOREST_OPENSSL_OPT_DIR" && \
    mkdir -p "$CRYPTOREST_OPENSSL_ETC_DIR" && \
    chmod 700 "$CRYPTOREST_OPENSSL_ETC_DIR"
}

letsencrypt_define()
{
    cp "$CRYPTOREST_MODULES_DIR/openssl/etc/"*.conf "$CRYPTOREST_OPENSSL_ETC_DIR/" && \
    chmod 400 "$CRYPTOREST_OPENSSL_ETC_DIR/"* && \
    cp "$CRYPTOREST_MODULES_DIR/openssl/opt/"*.sh "$CRYPTOREST_OPENSSL_OPT_DIR/" && \
    chmod 400 "$CRYPTOREST_OPENSSL_OPT_DIR/"*.sh
}


echo ''
echo "$CRYPTOREST_OPENSSL_TITLE: init"
echo ''

letsencrypt_prepare && \
letsencrypt_install && \
letsencrypt_define
