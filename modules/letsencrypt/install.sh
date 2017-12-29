#!/bin/sh

CRYPTOREST_LETSENCRYPT_NAME='letsencrypt'
CRYPTOREST_LETSENCRYPT_GIT_BRANCH="${CRYPTOREST_LETSENCRYPT_GIT_BRANCH:=master}"
CRYPTOREST_LETSENCRYPT_GIT_URL="https://github.com/$CRYPTOREST_LETSENCRYPT_NAME/$CRYPTOREST_LETSENCRYPT_NAME/archive/$CRYPTOREST_LETSENCRYPT_GIT_BRANCH.tar.gz"
CRYPTOREST_LETSENCRYPT_VAR_LOG_DIR="$CRYPTOREST_DIR/var/log/$CRYPTOREST_LETSENCRYPT_NAME"
CRYPTOREST_LETSENCRYPT_OPT_DIR="$CRYPTOREST_OPT_DIR/$CRYPTOREST_LETSENCRYPT_NAME"
CRYPTOREST_LETSENCRYPT_ETC_DIR="$CRYPTOREST_ETC_DIR/$CRYPTOREST_LETSENCRYPT_NAME"
CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE="$CRYPTOREST_LETSENCRYPT_ETC_DIR/.env"
CRYPTOREST_LETSENCRYPT_CERTBOT_DIR="$CRYPTOREST_LETSENCRYPT_OPT_DIR/certbot-$CRYPTOREST_LETSENCRYPT_GIT_BRANCH"
CRYPTOREST_LETSENCRYPT_BIN_FILE="$CRYPTOREST_BIN_DIR/cryptorest-$CRYPTOREST_LETSENCRYPT_NAME"

CRYPTOREST_LETSENCRYPT_URL="https://$CRYPTOREST_LETSENCRYPT_NAME.org/certs/"
CRYPTOREST_LETSENCRYPT_PEM_FILES='lets-encrypt-x4-cross-signed.pem lets-encrypt-x3-cross-signed.pem isrgrootx1.pem'
CRYPTOREST_LETSENCRYPT_TITLE="Let's Encrypt"

case "$(uname -m)" in
    x86_64 | amd64 )
        CRYPTOREST_LETSENCRYPT_ARCH='amd64'
    ;;
    x86 | i386 | i486 | i586 | i686 | i786 )
        CRYPTOREST_LETSENCRYPT_ARCH='386'
    ;;
    * )
        echo "ERROR: Current OS architecture has not been supported for $CRYPTOREST_LETSENCRYPT_TITLE"

        exit 1
    ;;
esac

case "$(uname -s)" in
    Linux )
        CRYPTOREST_LETSENCRYPT_OS='linux'
        CRYPTOREST_LETSENCRYPT_ETC_SYS_DIR='/etc/letsencrypt/live'
    ;;
    Darwin )
        CRYPTOREST_LETSENCRYPT_OS='darwin'
        CRYPTOREST_LETSENCRYPT_ETC_SYS_DIR='/usr/local/etc/letsencrypt/live'
    ;;
    FreeBSD )
        CRYPTOREST_LETSENCRYPT_OS="freebsd"
        CRYPTOREST_LETSENCRYPT_ETC_SYS_DIR='/usr/local/etc/letsencrypt/live'
    ;;
    * )
        echo "ERROR: Current OS does not supported for $CRYPTOREST_LETSENCRYPT_TITLE"

        exit 1
    ;;
esac


letsencrypt_prepare()
{
    rm -rf "$CRYPTOREST_LETSENCRYPT_OPT_DIR" && \
    rm -rf "$CRYPTOREST_LETSENCRYPT_ETC_DIR" && \
    rm -rf "$CRYPTOREST_LETSENCRYPT_CERTBOT_DIR" && \
    [ -d "$CRYPTOREST_BIN_DIR/" ] && \
    rm -f "$CRYPTOREST_LETSENCRYPT_BIN_FILE"*
}

letsencrypt_download()
{
    mkdir -p "$CRYPTOREST_LETSENCRYPT_OPT_DIR" && \
    cd "$CRYPTOREST_LETSENCRYPT_OPT_DIR" && \
    curl -SL "$CRYPTOREST_LETSENCRYPT_GIT_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "Some error with download"
        rm -rf "$CRYPTOREST_LETSENCRYPT_OPT_DIR"

        exit 1
    fi
}

letsencrypt_install()
{
    mkdir -p "$CRYPTOREST_LETSENCRYPT_ETC_DIR" && \
    chmod 700 "$CRYPTOREST_LETSENCRYPT_ETC_DIR" && \
    mkdir -p "$CRYPTOREST_LETSENCRYPT_VAR_LOG_DIR" && \
    chmod 700 "$CRYPTOREST_LETSENCRYPT_VAR_LOG_DIR" && \
    chmod 700 "$CRYPTOREST_LETSENCRYPT_CERTBOT_DIR" && \
    chmod 700 "$CRYPTOREST_LETSENCRYPT_OPT_DIR"
}

letsencrypt_define()
{
    cp "$CRYPTOREST_MODULES_DIR/$CRYPTOREST_LETSENCRYPT_NAME/opt/"*.sh "$CRYPTOREST_LETSENCRYPT_OPT_DIR/" && \
    chmod 400 "$CRYPTOREST_LETSENCRYPT_OPT_DIR/"*.sh && \
    ln -s "$CRYPTOREST_LETSENCRYPT_CERTBOT_DIR/certbot-auto" "$CRYPTOREST_LETSENCRYPT_BIN_FILE" && \
    chmod 500 "$CRYPTOREST_LETSENCRYPT_BIN_FILE" && \

    echo "# $CRYPTOREST_LETSENCRYPT_TITLE" > "$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE"
    echo "CRYPTOREST_LETSENCRYPT_ETC_SYS_DIR=\"$CRYPTOREST_LETSENCRYPT_ETC_SYS_DIR\"" >> "$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE"
    echo "CRYPTOREST_LETSENCRYPT_URL=\"$CRYPTOREST_LETSENCRYPT_URL\"" >> "$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE"
    echo "CRYPTOREST_LETSENCRYPT_PEM_FILES=\"$CRYPTOREST_LETSENCRYPT_PEM_FILES\"" >> "$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE"
    echo "CRYPTOREST_LETSENCRYPT_ARCH=\"$CRYPTOREST_LETSENCRYPT_ARCH\"" >> "$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE"
    echo "CRYPTOREST_LETSENCRYPT_OS=\"$CRYPTOREST_LETSENCRYPT_OS\"" >> "$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE"

    chmod 400 "$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE" && \

    echo ''
    echo "CRYPTOREST_LETSENCRYPT_* variables added in '$CRYPTOREST_LETSENCRYPT_ETC_ENV_FILE'"
    echo ''
}


echo ''
echo "$CRYPTOREST_LETSENCRYPT_TITLE branch: $CRYPTOREST_LETSENCRYPT_GIT_BRANCH"
echo "$CRYPTOREST_LETSENCRYPT_TITLE URL: $CRYPTOREST_LETSENCRYPT_GIT_URL"
echo ''

letsencrypt_prepare && \
letsencrypt_download && \
letsencrypt_install && \
letsencrypt_define
