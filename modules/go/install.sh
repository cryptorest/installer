#!/bin/sh

CRYPTOREST_GO_VERSION="${CRYPTOREST_GO_VERSION:=1.9.2}"
CRYPTOREST_GO="go$CRYPTOREST_GO_VERSION"
CRYPTOREST_GO_TITLE='Golang'

CRYPTOREST_GO_ETC_DIR="$CRYPTOREST_ETC_DIR/go"
CRYPTOREST_GO_ETC_ENV_FILE="$CRYPTOREST_GO_ETC_DIR/.env"
CRYPTOREST_GO_SRC_DIR="$CRYPTOREST_SRC_DIR/go"
CRYPTOREST_GO_TMP_DIR="$CRYPTOREST_TMP_DIR/$CRYPTOREST_GO"
CRYPTOREST_GO_BIN_FILE="$CRYPTOREST_BIN_DIR/cryptorest-go"
CRYPTOREST_GO_OPT_DIR="$CRYPTOREST_OPT_DIR/go"
CRYPTOREST_GO_OPT_VERSION_DIR="$CRYPTOREST_GO_OPT_DIR/$CRYPTOREST_GO"

case "$(uname -m)" in
    x86_64 | amd64 )
        CRYPTOREST_GO_ARCH='amd64'
    ;;
    x86 | i386 | i486 | i586 | i686 | i786 )
        CRYPTOREST_GO_ARCH='386'
    ;;
    * )
        echo "ERROR: Current OS architecture has not been supported for $CRYPTOREST_GO_TITLE"

        exit 1
    ;;
esac

case "$(uname -s)" in
    Linux )
        CRYPTOREST_GO_OS='linux'
    ;;
    Darwin )
        CRYPTOREST_GO_OS='darwin'
    ;;
    FreeBSD )
        CRYPTOREST_GO_OS="freebsd"
    ;;
    * )
        echo "ERROR: Current OS does not supported for $CRYPTOREST_GO_TITLE"

        exit 1
    ;;
esac

CRYPTOREST_GO_URL_SRC="https://go.googlesource.com/go/+archive/$CRYPTOREST_GO.tar.gz"
CRYPTOREST_GO_URL="https://redirector.gvt1.com/edgedl/go/$CRYPTOREST_GO.$CRYPTOREST_GO_OS-$CRYPTOREST_GO_ARCH.tar.gz"


#go_src_download()
#{
#    mkdir -p "$CRYPTOREST_GO_SRC_DIR" && \
#    cd "$CRYPTOREST_GO_SRC_DIR" && \
#    curl -SL "$CRYPTOREST_GO_URL_SRC" | tar -xz
#    if [ $? -ne 0 ]; then
#        echo "$CRYPTOREST_GO_TITLE: Some error with download"
#        rm -rf "$CRYPTOREST_GO_SRC_DIR"
#
#        exit 1
#    fi
#}

#go_build()
#{
#    cd "$CRYPTOREST_GO_SRC_DIR" && ./all.bash
#}

go_prepare()
{
    rm -rf "$CRYPTOREST_GO_ETC_DIR" && \
    rm -rf "$CRYPTOREST_GO_TMP_DIR" && \
    rm -rf "$CRYPTOREST_GO_OPT_DIR" && \
    rm -rf "$CRYPTOREST_GO_SRC_DIR" && \
    [ -d "$CRYPTOREST_BIN_DIR/" ] && \
    rm -f "$CRYPTOREST_BIN_DIR/go"* && \
    rm -f "$CRYPTOREST_GO_BIN_FILE"*
}

go_download()
{
    mkdir -p "$CRYPTOREST_GO_TMP_DIR" && \
    cd "$CRYPTOREST_GO_TMP_DIR" && \
    curl -SL "$CRYPTOREST_GO_URL" | tar -xz
    if [ $? -ne 0 ]; then
        echo "$CRYPTOREST_GO_TITLE: Some error with download"
        rm -rf "$CRYPTOREST_GO_TMP_DIR"

        exit 1
    fi
}

go_install()
{
    mkdir -p "$CRYPTOREST_GO_ETC_DIR" && \
    chmod 700 "$CRYPTOREST_GO_ETC_DIR" && \
    mkdir -p "$CRYPTOREST_GO_OPT_DIR" && \
    chmod 700 "$CRYPTOREST_GO_OPT_DIR" && \
    mkdir -p "$CRYPTOREST_GO_SRC_DIR" && \
    chmod 700 "$CRYPTOREST_GO_SRC_DIR" && \
    mv "$CRYPTOREST_GO_TMP_DIR/go" "$CRYPTOREST_GO_OPT_VERSION_DIR" && \
    rm -rf "$CRYPTOREST_GO_TMP_DIR" && \
    cp "$CRYPTOREST_MODULES_DIR/go/opt/"*.sh "$CRYPTOREST_GO_OPT_DIR/" && \
    chmod 400 "$CRYPTOREST_GO_OPT_DIR/"*.sh && \
    ln -s "$CRYPTOREST_GO_OPT_DIR/go.sh" "$CRYPTOREST_GO_BIN_FILE" && \
    chmod 500 "$CRYPTOREST_GO_BIN_FILE" && \
    [ -d "$CRYPTOREST_GO_OPT_VERSION_DIR/bin/" ] && \
    for f in $(ls "$CRYPTOREST_GO_OPT_VERSION_DIR/bin/go"*); do
        ln -s "$f" "$CRYPTOREST_BIN_DIR/$(basename $f)" && \
        chmod 500 "$f"
    done
}

go_define()
{
    echo "# $CRYPTOREST_GO_TITLE" > "$CRYPTOREST_GO_ETC_ENV_FILE"
    echo "export GOROOT=\"\$CRYPTOREST_DIR/opt/go/$CRYPTOREST_GO\"" >> "$CRYPTOREST_GO_ETC_ENV_FILE"
    echo "export GOPATH=\"\$CRYPTOREST_DIR/$(basename $CRYPTOREST_SRC_DIR)/go\"" >> "$CRYPTOREST_GO_ETC_ENV_FILE"
    echo "export PATH=\"\$GOROOT/bin:\$PATH\"" >> "$CRYPTOREST_GO_ETC_ENV_FILE"
    echo "export GOARCH=\"$CRYPTOREST_GO_ARCH\"" >> "$CRYPTOREST_GO_ETC_ENV_FILE"
    echo "export GOOS=\"$CRYPTOREST_GO_OS\"" >> "$CRYPTOREST_GO_ETC_ENV_FILE"
    chmod 400 "$CRYPTOREST_GO_ETC_ENV_FILE" && \

    echo ''
    echo "GOPATH, GOROOT, GOOS, GOARCH and in PATH added in '$CRYPTOREST_GO_ETC_ENV_FILE'"
    echo ''
}


echo ''
echo "$CRYPTOREST_GO_TITLE version: $CRYPTOREST_GO_VERSION"
echo "$CRYPTOREST_GO_TITLE source URL: $CRYPTOREST_GO_URL"
echo "$CRYPTOREST_GO_TITLE URL: $CRYPTOREST_GO_URL"
echo ''

go_prepare && \
go_download && \
go_install && \
go_define
