#!/bin/sh

# Shell utilities: echo, printf, chmod, chown, mkdir,
#                  ln, cp, ls, xargs, cat, exit, cut,
#                  dirname, basename, tr, grep, cd, rm
#
# System utilities: curl, tar, sed, uname

CRYPTOREST_CURRENT_DIR="$(cd $(dirname $0) && pwd -P)"

CRYPTOREST_CURRENT_ENV_FILE="$CRYPTOREST_CURRENT_DIR/.env"
CRYPTOREST_MAIN_LIBS_DIR="$CRYPTOREST_CURRENT_DIR"
if [ ! -f "$CRYPTOREST_CURRENT_ENV_FILE" ]; then
    CRYPTOREST_CURRENT_ENV_FILE="$CRYPTOREST_CURRENT_DIR/../.env"
    CRYPTOREST_MAIN_LIBS_DIR="$CRYPTOREST_CURRENT_DIR/.."
elif [ ! -f "$CRYPTOREST_CURRENT_ENV_FILE" ]; then
    CRYPTOREST_CURRENT_ENV_FILE="$CRYPTOREST_CURRENT_DIR/../../.env"
    CRYPTOREST_MAIN_LIBS_DIR="$CRYPTOREST_CURRENT_DIR/../.."
fi

echo ''
printf 'CryptoREST config file: '
if [ -f "$CRYPTOREST_CURRENT_ENV_FILE" ]; then
    . "$CRYPTOREST_CURRENT_ENV_FILE"
    [ $? -ne 0 ] && return 1

    echo 'loaded'
else
    echo 'not loaded'
fi


CRYPTOREST_CURRENT_DIR="$(cd $(dirname $0) && pwd -P)"

CRYPTOREST_DOMAIN="${CRYPTOREST_DOMAIN:=crypt.rest}"
CRYPTOREST_EMAIL="${CRYPTOREST_EMAIL:=$CRYPTOREST_DOMAIN@gmail.com}"
CRYPTOREST_SSL_BIT_SIZE="${CRYPTOREST_SSL_BIT_SIZE:=512}"
CRYPTOREST_SSL_BIT_KEY_SIZE="${CRYPTOREST_SSL_BIT_KEY_SIZE:=4096}"
CRYPTOREST_SSL_ECDH_CURVES="${CRYPTOREST_SSL_ECDH_CURVES:=secp521r1:secp384r1}"
CRYPTOREST_INSTALLER_DOMAIN="${CRYPTOREST_INSTALLER_DOMAIN:=get}"
CRYPTOREST_INSTALLER_GIT_BRANCH="${CRYPTOREST_INSTALLER_GIT_BRANCH:=master}"

CRYPTOREST_MAIN_LIBS='_common'
CRYPTOREST_MAIN_LIBS_LIST=''
CRYPTOREST_MAIN_LIBS_BIN_DIR="$CRYPTOREST_MAIN_LIBS_DIR/bin"
CRYPTOREST_IS_LOCAL=1
CRYPTOREST_HOME_SHELL_PROFILE_FILES='.bashrc .mkshrc .zshrc .cshrc .kshrc .rshrc'
CRYPTOREST_UTILITIES_LIST='curl tar sed uname'

CRYPTOREST_NAME='cryptorest'
CRYPTOREST_TITLE='CryptoREST'
CRYPTOREST_USER="$USER"
CRYPTOREST_DIR="$HOME/.$CRYPTOREST_NAME"
CRYPTOREST_ENV_FILE="$CRYPTOREST_DIR/.env"
CRYPTOREST_LIB_DIR="$CRYPTOREST_DIR/lib"
CRYPTOREST_OPT_DIR="$CRYPTOREST_DIR/opt"
CRYPTOREST_BIN_DIR="$CRYPTOREST_DIR/bin"
CRYPTOREST_SRC_DIR="$CRYPTOREST_DIR/src"
CRYPTOREST_WWW_DIR="$CRYPTOREST_DIR/www"
CRYPTOREST_VAR_DIR="$CRYPTOREST_DIR/var"
CRYPTOREST_VAR_LOG_DIR="$CRYPTOREST_VAR_DIR/log"
CRYPTOREST_VAR_RUN_DIR="$CRYPTOREST_VAR_DIR/run"
CRYPTOREST_ETC_DIR="$CRYPTOREST_DIR/etc"
CRYPTOREST_ETC_SSL_DIR="$CRYPTOREST_ETC_DIR/ssl"
CRYPTOREST_ETC_DOMAINS_DIR="$CRYPTOREST_ETC_DIR/.domains"
CRYPTOREST_TMP_DIR="${TMPDIR:=/tmp}/$CRYPTOREST_NAME"

CRYPTOREST_INSTALLER_NAME='installer'
CRYPTOREST_INSTALLER_GIT_URL="https://github.com/$CRYPTOREST_NAME/$CRYPTOREST_INSTALLER_NAME/archive/$CRYPTOREST_INSTALLER_GIT_BRANCH.tar.gz"
CRYPTOREST_INSTALLER_BIN_FILE="$CRYPTOREST_BIN_DIR/$CRYPTOREST_NAME-$CRYPTOREST_INSTALLER_NAME"
CRYPTOREST_INSTALLER_LIB_DIR="$CRYPTOREST_LIB_DIR/$CRYPTOREST_INSTALLER_NAME-$CRYPTOREST_INSTALLER_GIT_BRANCH"
CRYPTOREST_INSTALLER_LIB_BIN_DIR="$CRYPTOREST_INSTALLER_LIB_DIR/bin"
CRYPTOREST_INSTALLER_LIB_FILE="$CRYPTOREST_INSTALLER_LIB_DIR/bin.sh"
CRYPTOREST_INSTALLER_LIB_VERSION_FILE="$CRYPTOREST_INSTALLER_LIB_DIR/VERSION"
CRYPTOREST_INSTALLER_WWW_DIR="$CRYPTOREST_WWW_DIR/$CRYPTOREST_INSTALLER_DOMAIN"
CRYPTOREST_INSTALLER_WWW_HTML_FILE="$CRYPTOREST_INSTALLER_WWW_DIR/index.html"
CRYPTOREST_INSTALLER_WWW_ROBOTSTXT_FILE="$CRYPTOREST_INSTALLER_WWW_DIR/robots.txt"
CRYPTOREST_INSTALLER_IS_SITE=''
CRYPTOREST_INSTALLER_SITE='site'
CRYPTOREST_INSTALLER_ARGS="$*"


cryptorest_utilities_check()
{
    for u in $CRYPTOREST_UTILITIES_LIST; do
        "$u" --version 1> /dev/null
        if [ $? -ne 0 ]; then
            echo "$CRYPTOREST_TITLE check: '$u' not found or installed"
            echo ''

            exit 1
        fi
    done
}

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
    mkdir -p "$CRYPTOREST_OPT_DIR" && \
    chmod 700 "$CRYPTOREST_OPT_DIR" && \
    mkdir -p "$CRYPTOREST_SRC_DIR" && \
    chmod 700 "$CRYPTOREST_SRC_DIR" && \
    mkdir -p "$CRYPTOREST_BIN_DIR" && \
    chmod 700 "$CRYPTOREST_BIN_DIR" && \
    mkdir -p "$CRYPTOREST_ETC_DIR" && \
    chmod 700 "$CRYPTOREST_ETC_DIR" && \
    mkdir -p "$CRYPTOREST_WWW_DIR" && \
    chmod 700 "$CRYPTOREST_WWW_DIR" && \
    mkdir -p "$CRYPTOREST_TMP_DIR" && \
    chmod 700 "$CRYPTOREST_TMP_DIR" && \
    mkdir -p "$CRYPTOREST_LIB_DIR" && \
    chmod 700 "$CRYPTOREST_LIB_DIR" && \
    mkdir -p "$CRYPTOREST_VAR_DIR" && \
    chmod 700 "$CRYPTOREST_VAR_DIR" && \
    mkdir -p "$CRYPTOREST_VAR_LOG_DIR" && \
    chmod 700 "$CRYPTOREST_VAR_LOG_DIR" && \
    mkdir -p "$CRYPTOREST_VAR_RUN_DIR" && \
    chmod 700 "$CRYPTOREST_VAR_RUN_DIR" && \
    mkdir -p "$CRYPTOREST_INSTALLER_LIB_DIR" && \
    chmod 700 "$CRYPTOREST_INSTALLER_LIB_DIR" && \
    mkdir -p "$CRYPTOREST_INSTALLER_WWW_DIR" && \
    chmod 700 "$CRYPTOREST_INSTALLER_WWW_DIR" && \
    mkdir -p "$CRYPTOREST_ETC_SSL_DIR" && \
    chmod 700 "$CRYPTOREST_ETC_SSL_DIR" && \
    mkdir -p "$CRYPTOREST_ETC_DOMAINS_DIR" && \
    chmod 700 "$CRYPTOREST_ETC_DOMAINS_DIR" && \
    echo '' > "$CRYPTOREST_ENV_FILE" && \
    chmod 600 "$CRYPTOREST_ENV_FILE" && (

    echo "# $CRYPTOREST_TITLE" > "$CRYPTOREST_ENV_FILE"
    echo "export CRYPTOREST_DIR=\"$HOME/.$CRYPTOREST_NAME\"" >> "$CRYPTOREST_ENV_FILE"
    echo "export PATH=\"\$CRYPTOREST_DIR/bin:\$PATH\"" >> "$CRYPTOREST_ENV_FILE"
    echo '' >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_USER=\"$CRYPTOREST_USER\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_EMAIL=\"$CRYPTOREST_EMAIL\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_DOMAIN=\"$CRYPTOREST_DOMAIN\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_SSL_BIT_SIZE=\"$CRYPTOREST_SSL_BIT_SIZE\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_SSL_BIT_KEY_SIZE=\"$CRYPTOREST_SSL_BIT_KEY_SIZE\"" >> "$CRYPTOREST_ENV_FILE"
    echo "CRYPTOREST_SSL_ECDH_CURVES=\"$CRYPTOREST_SSL_ECDH_CURVES\"" >> "$CRYPTOREST_ENV_FILE"

    echo "$CRYPTOREST_TITLE structure: init")
}

cryptorest_is_local()
{
    for i in $CRYPTOREST_MAIN_LIBS; do
        if [ -d "$CRYPTOREST_MAIN_LIBS_DIR/$i" ] && [ -f "$CRYPTOREST_MAIN_LIBS_DIR/$i/install.sh" ]; then
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

    for i in $CRYPTOREST_MAIN_LIBS; do
        . "$CRYPTOREST_MAIN_LIBS_DIR/$i/install.sh"

        [ $? -ne 0 ] && return 1
    done

    cp "$CRYPTOREST_MAIN_LIBS_DIR/bin.sh" "$CRYPTOREST_INSTALLER_WWW_HTML_FILE" && \
    return 0
}

cryptorest_download()
{
    cd "$CRYPTOREST_LIB_DIR" && \
    curl -SL "$CRYPTOREST_INSTALLER_GIT_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "$CRYPTOREST_TITLE: Some errors with installer downloading"
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
    "$CRYPTOREST_INSTALLER_LIB_FILE" $CRYPTOREST_INSTALLER_ARGS
}

cryptorest_define()
{
    cryptorest_bin_installer_define && \
    ln -s "$CRYPTOREST__COMMON_WWW_HTML_ERRORS_DIR/" "$CRYPTOREST_INSTALLER_WWW_DIR/" && \
    ln -s "$CRYPTOREST__COMMON_WWW_ASSETS_DIR/" "$CRYPTOREST_INSTALLER_WWW_DIR/" && \
    ln -s "$CRYPTOREST__COMMON_WWW_ASSETS_ICONS_DIR/"* "$CRYPTOREST_INSTALLER_WWW_DIR/" && \
    cp "$CRYPTOREST_INSTALLER_LIB_FILE" "$CRYPTOREST_INSTALLER_WWW_DIR/index.html" && \
    chmod 444 "$CRYPTOREST_INSTALLER_WWW_DIR/index.html" && \
    chmod 400 "$CRYPTOREST_ENV_FILE" && \
    chmod 500 "$CRYPTOREST_INSTALLER_LIB_FILE" && \
    ln -s "$CRYPTOREST_INSTALLER_LIB_FILE" "$CRYPTOREST_INSTALLER_BIN_FILE" && \
    cryptorest_robotstxt_installer && \
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

cryptorest_profile_file_autoclean()
{
    local profile_file="$1"
    local file_backup="$profile_file.backup"

    cp "$profile_file" "$file_backup"
    [ -f "$file_backup" ] && \
    grep -v '[Cc][Rr][Yy][Pp][Tt][Oo][Rr][Ee][Ss][Tt]' "$file_backup" | cat -s > "$profile_file" && \
    rm -f "$file_backup"
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
                cryptorest_profile_file_autoclean "$profile_file"

                echo '' >> "$profile_file"
                echo "# $CRYPTOREST_TITLE" >> "$profile_file"
                echo ". \$HOME/.$CRYPTOREST_NAME/.env" >> "$profile_file"

                echo "    '$profile_file"
            fi
        done

        echo ''
        echo "$CRYPTOREST_TITLE$(cryptorest_version_define): installation successfully completed!"
        echo ''
    fi
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

    for f in $(ls "$CRYPTOREST_MAIN_LIBS_BIN_DIR/"*.sh); do
        file_name="$(basename -s .sh "$f")"
        html_dir="$CRYPTOREST_INSTALLER_WWW_DIR/$file_name"
        html_file="$html_dir/index.html"
        bin_file="$CRYPTOREST_INSTALLER_LIB_BIN_DIR/$(basename "$f")"

        CRYPTOREST_MAIN_LIBS_LIST="$CRYPTOREST_MAIN_LIBS_LIST $file_name"

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

cryptorest_robotstxt_installer()
{
(   echo "# $CRYPTOREST_TITLE Installer" > "$CRYPTOREST_INSTALLER_WWW_ROBOTSTXT_FILE"
    echo 'User-agent: *' >> "$CRYPTOREST_INSTALLER_WWW_ROBOTSTXT_FILE"
    echo 'Disallow: /' >> "$CRYPTOREST_INSTALLER_WWW_ROBOTSTXT_FILE"
    echo 'Allow: /' >> "$CRYPTOREST_INSTALLER_WWW_ROBOTSTXT_FILE"

    for l in $CRYPTOREST_MAIN_LIBS_LIST; do
        echo "Allow: /$l" >> "$CRYPTOREST_INSTALLER_WWW_ROBOTSTXT_FILE"
    done

    chmod 444 "$CRYPTOREST_INSTALLER_WWW_ROBOTSTXT_FILE") && \

    echo "$CRYPTOREST_TITLE Installer file robots.txt: init"
}

cryptorest_installer_site_difine()
{
    for a in $CRYPTOREST_INSTALLER_ARGS; do
        if [ "$a" = "$CRYPTOREST_INSTALLER_SITE" ]; then
            CRYPTOREST_INSTALLER_IS_SITE="$CRYPTOREST_INSTALLER_SITE"

            break
        fi
    done
}

cryptorest_domains_installer()
{
    cryptorest_installer_site_difine

    if [ "$CRYPTOREST_INSTALLER_IS_SITE" = "$CRYPTOREST_INSTALLER_SITE" ]; then
        echo "CRYPTOREST_LIB_DOMAIN=\"$CRYPTOREST_INSTALLER_DOMAIN.\$CRYPTOREST_DOMAIN\"" > "$CRYPTOREST_ETC_DOMAINS_DIR/$CRYPTOREST_INSTALLER_DOMAIN"
        echo "CRYPTOREST_DOMAINS=\"$CRYPTOREST_INSTALLER_DOMAIN.\$CRYPTOREST_DOMAIN\"" >> "$CRYPTOREST_ETC_DOMAINS_DIR/$CRYPTOREST_INSTALLER_DOMAIN"
    else
        rm -f "$CRYPTOREST_ETC_DOMAINS_DIR/$CRYPTOREST_INSTALLER_DOMAIN"
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

            if [ "$CRYPTOREST_CURRENT_DIR" != "$CRYPTOREST_INSTALLER_LIB_DIR" ]; then
                rm -f "$CRYPTOREST_INSTALLER_LIB_FILE" && \
                cp "$CRYPTOREST_MAIN_LIBS_DIR/bin.sh" "$CRYPTOREST_INSTALLER_LIB_FILE" && \
                cp "$CRYPTOREST_MAIN_LIBS_DIR/VERSION" "$CRYPTOREST_INSTALLER_LIB_VERSION_FILE" && \
                cp "$CRYPTOREST_MAIN_LIBS_DIR/README"* "$CRYPTOREST_INSTALLER_LIB_DIR/" && \

                status=$?
            fi
        else
            status=1
        fi

        [ $status -eq 0 ] && \
        cryptorest_define && \
        cryptorest_define_env_file && \
        cryptorest_domains_installer
    else
        cryptorest_network_install
    fi
}


cryptorest_utilities_check && \
cryptorest_init && \
cryptorest_install
