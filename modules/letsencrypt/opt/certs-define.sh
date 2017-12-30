#!/bin/sh

CRYPTOREST_LETSENCRYPT_KEYS='cert chain fullchain privkey'
CRYPTOREST_LETSENCRYPT_PRIVATE_KEY_FILE="$CRYPTOREST_SSL_DOMAIN_DIR/privkey.pem"


letsencrypt_log_dir_define()
{
    local domain="$1"

    mkdir -p "$CRYPTOREST_LETSENCRYPT_VAR_LOG_DIR/$CRYPTOREST_LIB_DOMAIN" && \
    chmod 700 "$CRYPTOREST_LETSENCRYPT_VAR_LOG_DIR/$CRYPTOREST_LIB_DOMAIN" && \
    chown "$CRYPTOREST_USER.$CRYPTOREST_USER" "$CRYPTOREST_LETSENCRYPT_VAR_LOG_DIR/$CRYPTOREST_LIB_DOMAIN"
}

letsencrypt_key_links()
{
    local current_dir="$(pwd -P)"

    cd "$CRYPTOREST_SSL_DOMAIN_DIR" && \
    for k in $CRYPTOREST_LETSENCRYPT_KEYS; do
        rm -f "$k.pem" && \
        ln -s "$CRYPTOREST_LETSENCRYPT_ETC_SYS_DIR/$CRYPTOREST_LIB_DOMAIN/$k.pem" "$k.pem"
    done
    cd "$current_dir"
}

# PUBLIC_KEY_PINS
letsencrypt_public_key_pins_define()
{
    local hash=''
    local ssl_bit_size=256  # CRYPTOREST_SSL_BIT_SIZE

    # Let's Encrypt
    for pem in $CRYPTOREST_LETSENCRYPT_PEM_FILES; do
        hash="$(curl -s "$CRYPTOREST_LETSENCRYPT_URL$pem" | openssl x509 -pubkey | openssl pkey -pubin -outform der | openssl dgst -sha$ssl_bit_size -binary | base64)"
        CRYPTOREST_PUBLIC_KEY_PINS="${CRYPTOREST_PUBLIC_KEY_PINS}pin-sha$ssl_bit_size=\"$hash\"; "
    done

    # RSA
    if [ -f "$CRYPTOREST_LETSENCRYPT_PRIVATE_KEY_FILE" ]; then
        hash="$(openssl rsa -pubout -in "$CRYPTOREST_LETSENCRYPT_PRIVATE_KEY_FILE" -outform DER | openssl dgst -sha$ssl_bit_size -binary | openssl enc -base64)"
        CRYPTOREST_PUBLIC_KEY_PINS="${CRYPTOREST_PUBLIC_KEY_PINS}pin-sha$ssl_bit_size=\"$hash\"; "
    fi
}

# OCSP
letsencrypt_ocsp_key_define()
{
    openssl ocsp -no_nonce \
        -url "http://$CRYPTOREST_LETSENCRYPT_OCSP_HOST" \
        -header Host="$CRYPTOREST_LETSENCRYPT_OCSP_HOST" \
        -respout "$CRYPTOREST_SSL_DOMAIN_DIR/ocsp.key" \
        -issuer "$CRYPTOREST_SSL_DOMAIN_DIR/chain.pem" \
        -VAfile "$CRYPTOREST_SSL_DOMAIN_DIR/chain.pem" \
        -cert "$CRYPTOREST_SSL_DOMAIN_DIR/cert.pem"
}
