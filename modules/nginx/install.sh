#!/bin/sh

CRYPTOREST_NGINX_OPT_DIR="$CRYPTOREST_OPT_DIR/nginx"
CRYPTOREST_NGINX_VAR_LOG_DIR="$CRYPTOREST_VAR_LOG_DIR/nginx"
CRYPTOREST_NGINX_ETC_DIR="$CRYPTOREST_ETC_DIR/nginx"
CRYPTOREST_NGINX_ETC_ENV_FILE="$CRYPTOREST_NGINX_ETC_DIR/.env"
CRYPTOREST_NGINX_TITLE='NGinx'
CRYPTOREST_NGINX_BIN_LETSENCRYPT_INIT_FILE="$CRYPTOREST_BIN_DIR/cryptorest-nginx-letsencrypt-init"
CRYPTOREST_NGINX_BIN_OPENSSL_INIT_FILE="$CRYPTOREST_BIN_DIR/cryptorest-nginx-openssl-init"
CRYPTOREST_NGINX_BIN_INIT_FILE="$CRYPTOREST_BIN_DIR/cryptorest-nginx-init"

case "$(uname -m)" in
    x86_64 | amd64 )
        CRYPTOREST_NGINX_ARCH='amd64'
    ;;
    x86 | i386 | i486 | i586 | i686 | i786 )
        CRYPTOREST_NGINX_ARCH='386'
    ;;
    * )
        echo "ERROR: Current OS architecture has not been supported for NGinx"

        exit 1
    ;;
esac

case "$(uname -s)" in
    Linux )
        CRYPTOREST_NGINX_OS='linux'
        CRYPTOREST_NGINX_CMD_START='systemctl start nginx'
        CRYPTOREST_NGINX_CMD_STOP='systemctl stop nginx'
    ;;
    Darwin )
        CRYPTOREST_NGINX_OS='darwin'
        CRYPTOREST_NGINX_CMD_START='brew services start nginx'
        CRYPTOREST_NGINX_CMD_STOP='brew services stop nginx'
    ;;
    FreeBSD )
        CRYPTOREST_NGINX_OS="freebsd"
        CRYPTOREST_NGINX_CMD_START='service nginx start'
        CRYPTOREST_NGINX_CMD_STOP='service nginx stop'
    ;;
    * )
        echo "ERROR: Current OS does not supported for $CRYPTOREST_NGINX_TITLE"

        exit 1
    ;;
esac


nginx_prepare()
{
    rm -f "$CRYPTOREST_BIN_DIR/cryptorest-nginx"* && \
    rm -rf "$CRYPTOREST_NGINX_ETC_DIR" && \
    rm -rf "$CRYPTOREST_NGINX_VAR_LOG_DIR" && \
    rm -rf "$CRYPTOREST_NGINX_OPT_DIR"
}

nginx_install()
{
    mkdir -p "$CRYPTOREST_NGINX_ETC_DIR" && \
    chmod 700 "$CRYPTOREST_NGINX_ETC_DIR" && \
    mkdir -p "$CRYPTOREST_NGINX_VAR_LOG_DIR" && \
    chmod 700 "$CRYPTOREST_NGINX_VAR_LOG_DIR" && \
    mkdir -p "$CRYPTOREST_NGINX_OPT_DIR" && \
    chmod 700 "$CRYPTOREST_NGINX_OPT_DIR"
}

nginx_define()
{
    cp "$CRYPTOREST_MODULES_DIR/nginx/etc/"*conf.template "$CRYPTOREST_NGINX_ETC_DIR/" && \
    cp "$CRYPTOREST_MODULES_DIR/nginx/etc/"*.conf "$CRYPTOREST_NGINX_ETC_DIR/" && \
    chmod 400 "$CRYPTOREST_NGINX_ETC_DIR/"* && \
    cp "$CRYPTOREST_MODULES_DIR/nginx/opt/"*.sh "$CRYPTOREST_NGINX_OPT_DIR/" && \
    chmod 400 "$CRYPTOREST_NGINX_OPT_DIR/"*.sh && \
    ln -s "$CRYPTOREST_NGINX_OPT_DIR/letsencrypt-init.sh" "$CRYPTOREST_NGINX_BIN_LETSENCRYPT_INIT_FILE" && \
    ln -s "$CRYPTOREST_NGINX_OPT_DIR/openssl-init.sh" "$CRYPTOREST_NGINX_BIN_OPENSSL_INIT_FILE" && \
    ln -s "$CRYPTOREST_NGINX_OPT_DIR/init.sh" "$CRYPTOREST_NGINX_BIN_INIT_FILE" && \
    chmod 500 "$CRYPTOREST_NGINX_OPT_DIR/"*init.sh && \

    echo "# $CRYPTOREST_NGINX_TITLE" > "$CRYPTOREST_NGINX_ETC_ENV_FILE"
    echo "CRYPTOREST_NGINX_CMD_START=\"$CRYPTOREST_NGINX_CMD_START\"" >> "$CRYPTOREST_NGINX_ETC_ENV_FILE"
    echo "CRYPTOREST_NGINX_CMD_STOP=\"$CRYPTOREST_NGINX_CMD_STOP\"" >> "$CRYPTOREST_NGINX_ETC_ENV_FILE"
    echo "CRYPTOREST_NGINX_ARCH=\"$CRYPTOREST_NGINX_ARCH\"" >> "$CRYPTOREST_NGINX_ETC_ENV_FILE"
    echo "CRYPTOREST_NGINX_OS=\"$CRYPTOREST_NGINX_OS\"" >> "$CRYPTOREST_NGINX_ETC_ENV_FILE"
    chmod 400 "$CRYPTOREST_NGINX_ETC_ENV_FILE" && \

    echo "CRYPTOREST_NGINX_* variables added in '$CRYPTOREST_NGINX_ETC_ENV_FILE'"
    echo ''
}


echo ''
echo "$CRYPTOREST_NGINX_TITLE: init"
echo ''

nginx_prepare && \
nginx_install && \
nginx_define
