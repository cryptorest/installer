#!/bin/sh

CRYPTOREST_OPENSSL_SERVER_CIPHERS='HIGH:!RC4:!aNULL:!eNULL:!LOW:!MD5:!DSS:!SSL:!CBC:!DSA:!3DES:!CAMELLIA:!ADH:!EXP:!PSK:!SRP:!EXPORT:!IDEA:!SEED'

CRYPTOREST_OPENSSL_DHPARAM_KEY_FILE="$CRYPTOREST_SSL_DOMAIN_DIR/dhparam.pem"
CRYPTOREST_OPENSSL_ECDSA_KEY_FILE="$CRYPTOREST_SSL_DOMAIN_DIR/ecdsa.key"
CRYPTOREST_OPENSSL_ECDSA_CSR_FILE="$CRYPTOREST_SSL_DOMAIN_DIR/ecdsa.csr"
CRYPTOREST_OPENSSL_SESSION_TICKET_FILE="$CRYPTOREST_SSL_DOMAIN_DIR/session_ticket.key"
CRYPTOREST_OPENSSL_CSR_CONF_FILE="$CRYPTOREST_OPENSSL_ETC_DIR/csr-$CRYPTOREST_DOMAIN.conf"


openssl_session_ticket_key_define()
{
    openssl rand 80 > "$CRYPTOREST_OPENSSL_SESSION_TICKET_FILE"
}

# Ciphers
openssl_ciphers_define()
{
    for k in $(openssl ciphers | tr ':' ' '); do
        echo "$k" | grep '128' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'MD5' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'RC4' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'EXP' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'PSK' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'CBC' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'SRP' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep '^DHE' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'SHA$' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'ADH' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'DSA' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'DSS' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'SSL' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep '3DES' > /dev/null
        [ $? -eq 0 ] && continue
        echo "$k" | grep 'CAMELLIA' > /dev/null
        [ $? -eq 0 ] && continue

        CRYPTOREST_OPENSSL_SERVER_CIPHERS="$CRYPTOREST_OPENSSL_SERVER_CIPHERS:$k"
    done
}

# HD Param
openssl_hd_param_define()
{
    openssl dhparam -out "$CRYPTOREST_OPENSSL_DHPARAM_KEY_FILE" "$CRYPTOREST_SSL_BIT_KEY_SIZE"
}

openssl_ecdh_curves_define()
{
    openssl ecparam -list_curves | grep 'r1' | cut -d ':' -f 1 | grep -E "[3][8][4]|[5][1][2]|[5][2][1]" | xargs | tr ' ' ':'
}

# ECDSA
openssl_ecdsa_define()
{
    [ -z "$CRYPTOREST_SSL_ECDH_CURVES" ] && CRYPTOREST_SSL_ECDH_CURVES="$(openssl_ecdh_curves_define)"

    openssl ecparam -genkey -name "$CRYPTOREST_SSL_ECDH_CURVES" | openssl ec -out "$CRYPTOREST_OPENSSL_ECDSA_KEY_FILE"
}

# Certificate Signing Request (CSR)
openssl_csr_define()
{
    openssl req -new -sha$CRYPTOREST_SSL_BIT_SIZE -key "$CRYPTOREST_OPENSSL_ECDSA_KEY_FILE" -nodes -out "$CRYPTOREST_OPENSSL_ECDSA_CSR_FILE" -outform pem
}

# ECDSA
openssl_ecdsa_define__()
{
    if [ -f "$CRYPTOREST_OPENSSL_CSR_CONF_FILE" ]; then
        openssl req -new -sha$CRYPTOREST_SSL_BIT_SIZE -key "$CRYPTOREST_OPENSSL_PRIVATE_KEY_FILE" -out "$CRYPTOREST_OPENSSL_ECDSA_CSR_FILE" -subj "/CN=$CRYPTOREST_DOMAIN" -config "$CRYPTOREST_OPENSSL_CSR_CONF_FILE"
#        openssl ecparam -genkey -name secp384r1 | openssl ec -out "$CRYPTOREST_OPENSSL_ECDSA_KEY_FILE"
#        openssl req -new -sha256 -key "$CRYPTOREST_OPENSSL_ECDSA_CSR_FILE" -nodes -out "$CRYPTOREST_OPENSSL_ECDSA_CSR_FILE" -outform pem
    fi
}

# PUBLIC_KEY_PINS
openssl_public_key_pins_define()
{
    local hash=''

    # ECDSA
    hash="$(openssl ec -pubout -in "$CRYPTOREST_OPENSSL_ECDSA_CSR_FILE" -outform DER | openssl dgst -sha$CRYPTOREST_SSL_BIT_SIZE -binary | openssl enc -base64)"
    CRYPTOREST_PUBLIC_KEY_PINS="${CRYPTOREST_PUBLIC_KEY_PINS}pin-sha$CRYPTOREST_SSL_BIT_SIZE=\"${hash}\"; "
}
