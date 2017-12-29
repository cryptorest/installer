#!/bin/sh

CURRENT_DIR="$(cd $(dirname $0) && pwd -P)"

CRYPTOREST_ENV_FILE="$CURRENT_DIR/.env"
CRYPTOREST_MAIN_MODULES_DIR="$CURRENT_DIR"
if [ ! -f "$CRYPTOREST_ENV_FILE" ]; then
    CRYPTOREST_ENV_FILE="$CURRENT_DIR/../.env"
    CRYPTOREST_MAIN_MODULES_DIR="$CURRENT_DIR/.."
elif [ ! -f "$CRYPTOREST_ENV_FILE" ]; then
    CRYPTOREST_ENV_FILE="$CURRENT_DIR/../../.env"
    CRYPTOREST_MAIN_MODULES_DIR="$CURRENT_DIR/../.."
fi

echo ''
printf 'CrypotREST config file: '
if [ -f "$CRYPTOREST_ENV_FILE" ]; then
    . "$CRYPTOREST_ENV_FILE"

    echo 'loaded'
else
    echo 'not loaded'
fi

CURRENT_DIR="$(cd $(dirname $0) && pwd -P)"

CRYPTOREST_DOMAIN="${CRYPTOREST_DOMAIN:=crypt.rest}"
CRYPTOREST_DOMAINS="${CRYPTOREST_DOMAINS:=$CRYPTOREST_DOMAIN www.$CRYPTOREST_DOMAIN gui.$CRYPTOREST_DOMAIN api.$CRYPTOREST_DOMAIN installer.$CRYPTOREST_DOMAIN}"
CRYPTOREST_EMAIL="${CRYPTOREST_EMAIL:=$CRYPTOREST_DOMAIN@gmail.com}"
CRYPTOREST_SSL_DOMAINS="${CRYPTOREST_SSL_DOMAINS:=$CRYPTOREST_DOMAIN *.$CRYPTOREST_DOMAIN}"
CRYPTOREST_SSL_KEY_SIZE="${CRYPTOREST_SSL_KEY_SIZE:=4096}"
CRYPTOREST_SSL_BITS="${CRYPTOREST_SSL_BITS:=256}"
CRYPTOREST_GIT_BRANCH="${CRYPTOREST_GIT_BRANCH:=master}"

CRYPTOREST_MAIN_MODULES='_common'
CRYPTOREST_MAIN_MODULES_BIN_DIR="$CRYPTOREST_MAIN_MODULES_DIR/bin"
CRYPTOREST_IS_LOCAL=1
CRYPTOREST_HOME_SHELL_PROFILE_FILES=".bashrc .mkshrc .zshrc .cshrc .kshrc"

CRYPTOREST_GIT_URL="https://github.com/cryptorest/installer/archive/$CRYPTOREST_GIT_BRANCH.tar.gz"
CRYPTOREST_TITLE='CryptoREST'
CRYPTOREST_USER="$USER"
CRYPTOREST_DIR="$HOME/.cryptorest"
CRYPTOREST_ENV_FILE="$CRYPTOREST_DIR/.env"
CRYPTOREST_LIB_DIR="$CRYPTOREST_DIR/lib"
CRYPTOREST_OPT_DIR="$CRYPTOREST_DIR/opt"
CRYPTOREST_BIN_DIR="$CRYPTOREST_DIR/bin"
CRYPTOREST_SRC_DIR="$CRYPTOREST_DIR/src"
CRYPTOREST_ETC_DIR="$CRYPTOREST_DIR/etc"
CRYPTOREST_LOG_DIR="$CRYPTOREST_DIR/log"
CRYPTOREST_WWW_DIR="$CRYPTOREST_DIR/www"
CRYPTOREST_VAR_DIR="$CRYPTOREST_DIR/var"
CRYPTOREST_SSL_DIR="$CRYPTOREST_DIR/ssl"
CRYPTOREST_SSL_CRYPTOREST_DIR="$CRYPTOREST_SSL_DIR/cryptorest"
CRYPTOREST_TMP_DIR="${TMPDIR:=/tmp}/cryptorest"

CRYPTOREST_INSTALLER_BIN_FILE="$CRYPTOREST_BIN_DIR/cryptorest-installer"
CRYPTOREST_INSTALLER_LIB_DIR="$CRYPTOREST_LIB_DIR/installer-$CRYPTOREST_GIT_BRANCH"
CRYPTOREST_INSTALLER_LIB_BIN_DIR="$CRYPTOREST_INSTALLER_LIB_DIR/bin"
CRYPTOREST_INSTALLER_LIB_FILE="$CRYPTOREST_INSTALLER_LIB_DIR/bin.sh"
CRYPTOREST_INSTALLER_LIB_VERSION_FILE="$CRYPTOREST_INSTALLER_LIB_DIR/VERSION"
CRYPTOREST_INSTALLER_WWW_DIR="$CRYPTOREST_WWW_DIR/installer"
CRYPTOREST_INSTALLER_WWW_HTML_FILE="$CRYPTOREST_INSTALLER_WWW_DIR/index.html"


cryptorest_prepare()
{
(   if [ -d ""$CRYPTOREST_WWW_DIR"" ]; then
        chmod 700 "$CRYPTOREST_WWW_DIR"
    fi

    if [ -d ""$CRYPTOREST_INSTALLER_WWW_DIR"" ]; then
        chmod 700 "$CRYPTOREST_INSTALLER_WWW_DIR" && \
        for d in $(ls "$CRYPTOREST_INSTALLER_WWW_DIR/"); do
            [ -d "$CRYPTOREST_INSTALLER_WWW_DIR/$d" ] && \
            chmod -R 700 "$CRYPTOREST_INSTALLER_WWW_DIR/$d" && \
            rm -rf "$CRYPTOREST_INSTALLER_WWW_DIR/$d"
        done

        rm -rf "$CRYPTOREST_INSTALLER_WWW_DIR"
    fi) && \

    rm -f "$CRYPTOREST_ENV_FILE" && \
    rm -f "$CRYPTOREST_INSTALLER_BIN_FILE"
}

cryptorest_init()
{
    cryptorest_prepare && \
    mkdir -p "$CRYPTOREST_DIR" && \
    chmod 755 "$CRYPTOREST_DIR" && \
    mkdir -p "$CRYPTOREST_VAR_DIR" && \
    chmod 700 "$CRYPTOREST_VAR_DIR" && \
    mkdir -p "$CRYPTOREST_OPT_DIR" && \
    chmod 700 "$CRYPTOREST_OPT_DIR" && \
    mkdir -p "$CRYPTOREST_SRC_DIR" && \
    chmod 700 "$CRYPTOREST_SRC_DIR" && \
    mkdir -p "$CRYPTOREST_BIN_DIR" && \
    chmod 700 "$CRYPTOREST_BIN_DIR" && \
    mkdir -p "$CRYPTOREST_ETC_DIR" && \
    chmod 700 "$CRYPTOREST_ETC_DIR" && \
    mkdir -p "$CRYPTOREST_LOG_DIR" && \
    chmod 700 "$CRYPTOREST_LOG_DIR" && \
    mkdir -p "$CRYPTOREST_WWW_DIR" && \
    chmod 700 "$CRYPTOREST_WWW_DIR" && \
    mkdir -p "$CRYPTOREST_TMP_DIR" && \
    chmod 700 "$CRYPTOREST_TMP_DIR" && \
    mkdir -p "$CRYPTOREST_LIB_DIR" && \
    chmod 700 "$CRYPTOREST_LIB_DIR" && \
    mkdir -p "$CRYPTOREST_SSL_DIR" && \
    chmod 700 "$CRYPTOREST_SSL_DIR" && \
    mkdir -p "$CRYPTOREST_SSL_CRYPTOREST_DIR" && \
    chmod 700 "$CRYPTOREST_SSL_CRYPTOREST_DIR" && \
    mkdir -p "$CRYPTOREST_INSTALLER_LIB_DIR" && \
    chmod 700 "$CRYPTOREST_INSTALLER_LIB_DIR" && \
    mkdir -p "$CRYPTOREST_INSTALLER_WWW_DIR" && \
    chmod 700 "$CRYPTOREST_INSTALLER_WWW_DIR" && \
    echo '' > "$CRYPTOREST_ENV_FILE" && \
    chmod 600 "$CRYPTOREST_ENV_FILE" && (

    echo "# $CRYPTOREST_TITLE" > "$CRYPTOREST_ENV_FILE"
    echo "export CRYPTOREST_DIR=\"$HOME/.cryptorest\"" >> "$CRYPTOREST_ENV_FILE"
    echo "export PATH=\"\$CRYPTOREST_DIR/bin:\$PATH\"" >> "$CRYPTOREST_ENV_FILE"
    echo '' >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_USER=\"$CRYPTOREST_USER\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_EMAIL=\"$CRYPTOREST_EMAIL\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_DOMAIN=\"$CRYPTOREST_DOMAIN\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_DOMAINS=\"$CRYPTOREST_DOMAINS\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_SSL_DOMAINS=\"$CRYPTOREST_SSL_DOMAINS\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_SSL_KEY_SIZE=\"$CRYPTOREST_SSL_KEY_SIZE\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_SSL_BITS=\"$CRYPTOREST_SSL_BITS\"" >> "$CRYPTOREST_ENV_FILE"
    echo '' >> "$CRYPTOREST_ENV_FILE"
    echo '' >> "$CRYPTOREST_ENV_FILE"

    echo "$CRYPTOREST_TITLE structure: init")
}

cryptorest_is_local()
{
    for i in $CRYPTOREST_MAIN_MODULES; do
        if [ -d "$CRYPTOREST_MAIN_MODULES_DIR/$i" ] && [ -f "$CRYPTOREST_MAIN_MODULES_DIR/$i/install.sh" ]; then
            CRYPTOREST_IS_LOCAL=0

            break
        fi
    done

    return $CRYPTOREST_IS_LOCAL
}

cryptorest_local_install()
{
    echo "$CRYPTOREST_TITLE mode: local"
    echo ''

    for i in $CRYPTOREST_MAIN_MODULES; do
        . "$CRYPTOREST_MAIN_MODULES_DIR/$i/install.sh"

        [ $? -ne 0 ] && return 1
    done

    cp "$CRYPTOREST_MAIN_MODULES_DIR/bin.sh" "$CRYPTOREST_INSTALLER_WWW_HTML_FILE" && \
    return 0
}

cryptorest_download()
{
    cd "$CRYPTOREST_LIB_DIR" && \
    curl -SL "$CRYPTOREST_GIT_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "$CRYPTOREST_TITLE: Some errors with download"
        rm -rf "$CRYPTOREST_DIR"

        exit 1
    fi
}

cryptorest_network_install()
{
    echo "$CRYPTOREST_TITLE mode: network"
    echo ''

    cryptorest_download && \
    cp "$CRYPTOREST_INSTALLER_LIB_FILE" "$CRYPTOREST_INSTALLER_WWW_HTML_FILE" && \
    "$CRYPTOREST_INSTALLER_LIB_FILE"
}

cryptorest_bin_installer_define()
{
    local html_file=''
    local html_dir=''
    local bin_file=''
    local file_name=''

    [ -d "$CRYPTOREST_INSTALLER_LIB_BIN_DIR" ] && \
    [ ! -z "$(ls "$CRYPTOREST_INSTALLER_LIB_BIN_DIR")" ] && \
    chmod 700 "$CRYPTOREST_INSTALLER_LIB_BIN_DIR/"*.sh

    mkdir -p "$CRYPTOREST_INSTALLER_LIB_BIN_DIR" && \
    chmod 700 "$CRYPTOREST_INSTALLER_LIB_BIN_DIR" && \
    rm -f "$CRYPTOREST_INSTALLER_BIN_FILE"* && \

    for f in $(ls "$CRYPTOREST_MAIN_MODULES_BIN_DIR/"*.sh); do
        file_name="$(basename -s .sh "$f")"
        html_dir="$CRYPTOREST_INSTALLER_WWW_DIR/$file_name"
        html_file="$html_dir/index.html"
        bin_file="$CRYPTOREST_INSTALLER_LIB_BIN_DIR/$(basename "$f")"

        if [ "$f" != "$bin_file" ]; then
            cp "$f" "$bin_file" && \
            chmod 500 "$bin_file"
        fi

        mkdir -p "$html_dir" && \
        cp "$bin_file" "$html_file" && \
        chmod 444 "$html_file" && \
        chmod 555 "$html_dir" && \
        ln -s "$bin_file" "$CRYPTOREST_INSTALLER_BIN_FILE-$file_name"
    done
}

cryptorest_define()
{
    cryptorest_bin_installer_define && \
    chmod 444 "$CRYPTOREST_INSTALLER_WWW_HTML_FILE" && \
    ln -s "$CRYPTOREST__COMMON_WWW_ERRORS_DIR/" "$CRYPTOREST_INSTALLER_WWW_DIR/" && \
    chmod 400 "$CRYPTOREST_ENV_FILE" && \
    chmod 500 "$CRYPTOREST_INSTALLER_LIB_FILE" && \
    ln -s "$CRYPTOREST_INSTALLER_LIB_FILE" "$CRYPTOREST_INSTALLER_BIN_FILE" && \
    chmod 555 "$CRYPTOREST_INSTALLER_WWW_DIR" && \
    chmod 555 "$CRYPTOREST_WWW_DIR"
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

cryptorest_define_env_file()
{
    local profile_file=''

    if [ $? -eq 0 ]; then
        echo ''
        echo "$CRYPTOREST_TITLE ENV added in following profile file(s):"

        for shell_profile_file in $CRYPTOREST_HOME_SHELL_PROFILE_FILES; do
            profile_file="$HOME/$shell_profile_file"

            if [ -f "$profile_file" ]; then
                echo '' >> "$profile_file"
                echo "# $CRYPTOREST_TITLE" >> "$profile_file"
                echo ". \$HOME/.cryptorest/.env" >> "$profile_file"

                echo "    '$profile_file"
            fi
        done

        echo ''
        echo "$CRYPTOREST_TITLE$(cryptorest_version_define): installation successfully completed!"
        echo ''
    fi
}

cryptorest_install()
{
    local status=0

    cryptorest_is_local
    if [ $? -eq 0 ]; then
        cryptorest_local_install
        if [ $? -eq 0 ]; then
            status=0

            if [ "$CURRENT_DIR" != "$CRYPTOREST_INSTALLER_LIB_DIR" ]; then
                rm -f "$CRYPTOREST_INSTALLER_LIB_DIR/bin.sh" && \
                cp "$CRYPTOREST_MAIN_MODULES_DIR/bin.sh" "$CRYPTOREST_INSTALLER_LIB_DIR/bin.sh" && \
                cp "$CRYPTOREST_MAIN_MODULES_DIR/VERSION" "$CRYPTOREST_INSTALLER_LIB_VERSION_FILE" && \
                cp "$CRYPTOREST_MAIN_MODULES_DIR/README"* "$CRYPTOREST_INSTALLER_LIB_DIR/" && \
                status=$?
            fi
        else
            status=1
        fi
        [ $status -eq 0 ] && \
        cryptorest_define && \
        cryptorest_define_env_file
    else
        cryptorest_network_install
    fi
}


cryptorest_init && \
cryptorest_install
