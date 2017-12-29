#!/bin/sh

CURRENT_DIR="$(cd $(dirname "$0") && pwd -P)"

CRYPTOREST_ENV_FILE="$CURRENT_DIR/../.env"
CRYPTOREST_MODULES_DIR="$CURRENT_DIR/../modules"
if [ ! -f "$CRYPTOREST_ENV_FILE" ]; then
    CRYPTOREST_ENV_FILE="$CURRENT_DIR/../../../.env"
fi
if [ ! -d "$CRYPTOREST_MODULES_DIR" ]; then
    CRYPTOREST_MODULES_DIR="$(readlink "$0")"

    if [ -z "$CRYPTOREST_MODULES_DIR" ]; then
        CRYPTOREST_MODULES_DIR="$(dirname "$0")"
    else
        CRYPTOREST_MODULES_DIR="$(dirname "$CRYPTOREST_MODULES_DIR")"
    fi
    CRYPTOREST_MODULES_DIR="$CRYPTOREST_MODULES_DIR/../modules"
fi

echo ''
printf 'CryptoREST config file: '
if [ -f "$CRYPTOREST_ENV_FILE" ]; then
    . "$CRYPTOREST_ENV_FILE"

    echo 'loaded'
else
    echo 'not loaded'
fi


CURRENT_DIR="$(cd $(dirname "$0") && pwd -P)"

# CRYPTOREST_MODULES='go nginx openssl letsencrypt'
CRYPTOREST_MODULES="${CRYPTOREST_MODULES:=}"
CRYPTOREST_INSTALLER_GIT_BRANCH="${CRYPTOREST_INSTALLER_GIT_BRANCH:=master}"

CRYPTOREST_NAME='cryptorest'
CRYPTOREST_TITLE='CryptoREST Modules'
CRYPTOREST_INSTALLER_GIT_URL="https://github.com/$CRYPTOREST_NAME/installer/archive/$CRYPTOREST_INSTALLER_GIT_BRANCH.tar.gz"
CRYPTOREST_USER="$USER"
CRYPTOREST_DIR="$HOME/.$CRYPTOREST_NAME"
CRYPTOREST_ENV_FILE="$CRYPTOREST_DIR/.env"
CRYPTOREST_LIB_DIR="$CRYPTOREST_DIR/lib"
CRYPTOREST_OPT_DIR="$CRYPTOREST_DIR/opt"
CRYPTOREST_BIN_DIR="$CRYPTOREST_DIR/bin"
CRYPTOREST_SRC_DIR="$CRYPTOREST_DIR/src"
CRYPTOREST_ETC_DIR="$CRYPTOREST_DIR/etc"
CRYPTOREST_WWW_DIR="$CRYPTOREST_DIR/www"
CRYPTOREST_VAR_DIR="$CRYPTOREST_DIR/var"
CRYPTOREST_VAR_LOG_DIR="$CRYPTOREST_VAR_DIR/log"
CRYPTOREST_ETC_SSL_DIR="$CRYPTOREST_ETC_DIR/ssl"
CRYPTOREST_TMP_DIR="${TMPDIR:=/tmp}/$CRYPTOREST_NAME"
CRYPTOREST_MUDULES_LIB_BIN_DIR="$CRYPTOREST_LIB_DIR/installer-$CRYPTOREST_INSTALLER_GIT_BRANCH/bin"
CRYPTOREST_INSTALLER_LIB_VERSION_FILE="$CRYPTOREST_MUDULES_LIB_BIN_DIR/../VERSION"
CRYPTOREST_MUDULES_LIB_BIN_FILE="$CRYPTOREST_MUDULES_LIB_BIN_DIR/modules.sh"

CRYPTOREST_MODULES_ALL='all'
CRYPTOREST_MODULES_DEFAULT='go'
CRYPTOREST_MODULES_ARGS="$*"
CRYPTOREST_IS_LOCAL=1


cryptorest_init()
{
    mkdir -p "$CRYPTOREST_OPT_DIR" && \
    chmod 700 "$CRYPTOREST_OPT_DIR" && \
    mkdir -p "$CRYPTOREST_SRC_DIR" && \
    chmod 700 "$CRYPTOREST_SRC_DIR" && \
    mkdir -p "$CRYPTOREST_BIN_DIR" && \
    chmod 700 "$CRYPTOREST_BIN_DIR" && \
    mkdir -p "$CRYPTOREST_TMP_DIR" && \
    chmod 700 "$CRYPTOREST_TMP_DIR" && \
    mkdir -p "$CRYPTOREST_LIB_DIR" && \
    chmod 700 "$CRYPTOREST_LIB_DIR" && \
    mkdir -p "$CRYPTOREST_ETC_DIR" && \
    chmod 700 "$CRYPTOREST_ETC_DIR" && \
    mkdir -p "$CRYPTOREST_ETC_SSL_DIR" && \
    chmod 700 "$CRYPTOREST_ETC_SSL_DIR" && \
    mkdir -p "$CRYPTOREST_VAR_DIR" && \
    chmod 700 "$CRYPTOREST_VAR_DIR" && \
    mkdir -p "$CRYPTOREST_VAR_LOG_DIR" && \
    chmod 700 "$CRYPTOREST_VAR_LOG_DIR" && \
    mkdir -p "$CRYPTOREST_MUDULES_LIB_BIN_DIR" && \
    chmod 700 "$CRYPTOREST_MUDULES_LIB_BIN_DIR" && \

    echo "$CRYPTOREST_TITLE structure: check"
}

cryptorest_modules()
{
    local modules=''

    [ -z "$CRYPTOREST_MODULES_ARGS" ] && \
    [ -z "$CRYPTOREST_MODULES" ] && \
    CRYPTOREST_MODULES_ARGS="$CRYPTOREST_MODULES_DEFAULT"

    if [ -z "$CRYPTOREST_MODULES_ARGS" ]; then
        modules="$CRYPTOREST_MODULES"
    else
        modules="$CRYPTOREST_MODULES_ARGS"
    fi

    [ "$modules" = "$CRYPTOREST_MODULES_ALL" ] && modules="$(ls "$CRYPTOREST_MODULES_DIR")"

    CRYPTOREST_MODULES=''

    for m in $modules; do
        if [ -d "$CRYPTOREST_MODULES_DIR/$m" ] && [ -f "$CRYPTOREST_MODULES_DIR/$m/install.sh" ]; then
            CRYPTOREST_MODULES="$CRYPTOREST_MODULES $m"
        else
            echo "$CRYPTOREST_TITLE WARNING: module '$m' does not exist"
        fi
    done
}

cryptorest_is_local()
{
    if [ -d "$CRYPTOREST_MODULES_DIR/" ]; then
        for m in $(ls "$CRYPTOREST_MODULES_DIR"); do
            if [ -d "$CRYPTOREST_MODULES_DIR/$m" ] && [ -f "$CRYPTOREST_MODULES_DIR/$m/install.sh" ]; then
                CRYPTOREST_IS_LOCAL=0

                break
            fi
        done
    fi

    return $CRYPTOREST_IS_LOCAL
}

cryptorest_local_install()
{
    echo "$CRYPTOREST_TITLE mode: local"
    echo ''

    for m in $(echo "$CRYPTOREST_MODULES" | sort); do
        . "$CRYPTOREST_MODULES_DIR/$m/install.sh"
        [ $? -ne 0 ] && return 1
    done

    return 0
}

cryptorest_download()
{
    cd "$CRYPTOREST_LIB_DIR" && \
    curl -SL "$CRYPTOREST_INSTALLER_GIT_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "$CRYPTOREST_TITLE: Some errors with download"
        rm -rf "$CRYPTOREST_MUDULES_LIB_BIN_DIR"

        exit 1
    fi
}

cryptorest_network_install()
{
    echo "$CRYPTOREST_TITLE mode: network"
    echo ''

    cryptorest_download && \
    CRYPTOREST_MODULES="$CRYPTOREST_MODULES" "$CRYPTOREST_MODULES_LIB_BIN_FILE" $CRYPTOREST_MODULES_ARGS
}

cryptorest_version_define()
{
    local version=''
    local message=''

    if [ -f "$CRYPTOREST_INSTALLER_LIB_VERSION_FILE" ]; then
        version="$(cat "$CRYPTOREST_INSTALLER_LIB_VERSION_FILE")"
        message=" (version: $version)"
    fi

    echo "$message"
}

cryptorest_define()
{
    if [ $? -eq 0 ]; then
        echo ''
        echo "$CRYPTOREST_TITLE$(cryptorest_version_define): installation successfully completed!"
        echo ''
    fi
}

cryptorest_install()
{
    local status=0
    local modules_bin_dir=''

    cryptorest_is_local
    if [ $? -eq 0 ]; then
        cryptorest_local_install
        if [ $? -eq 0 ]; then
            status=0
            modules_bin_dir="$(cd "$CRYPTOREST_MODULES_DIR/../bin" && pwd -P)"

            if [ "$modules_bin_dir" != "$CRYPTOREST_MUDULES_LIB_BIN_DIR" ]; then
                rm -f "$CRYPTOREST_MUDULES_LIB_BIN_FILE" && \
                cp "$modules_bin_dir/modules.sh" "$CRYPTOREST_MUDULES_LIB_BIN_FILE"
            fi

            chmod 500 "$CRYPTOREST_MUDULES_LIB_BIN_FILE" && \
            status=$?
        else
            status=1
        fi
        [ $status -eq 0 ] && cryptorest_define
    else
        cryptorest_network_install
    fi
}


cryptorest_modules && \
cryptorest_init && \
cryptorest_install
