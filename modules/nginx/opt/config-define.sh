#!/bin/sh

CRYPTOREST_NGINX_CONF_TEMPLATE_FILE_EXT='conf.template'


nginx_log_dir_define()
{
    local domain="$1"

    mkdir -p "$CRYPTOREST_NGINX_VAR_LOG_DIR/$domain" && \
    chmod 700 "$CRYPTOREST_NGINX_VAR_LOG_DIR/$domain" && \
    chown "$CRYPTOREST_USER.$CRYPTOREST_USER" "$CRYPTOREST_NGINX_VAR_LOG_DIR/$domain"
}

nginx_links_define()
{
    local conf_file="$1"
    local conf_file_name="$(basename "$conf_file")"

    rm -f "/etc/nginx/conf.d/$conf_file_name" && \
    ln -s "$conf_file" "/etc/nginx/conf.d/$conf_file_name" && \
    rm -f "/etc/nginx/sites-available/$conf_file_name" && \
    ln -s "$conf_file" "/etc/nginx/sites-available/$conf_file_name" && \
    rm -f "/etc/nginx/sites-enabled/$conf_file_name" && \
    ln -s "/etc/nginx/sites-available/$conf_file_name" "/etc/nginx/sites-enabled/$conf_file_name" && \

    nginx -t
}

nginx_config_define()
{
    local domain="$1"
    local conf_file="$2"
    local template_file="$3"

    cp -f "$template_file" "$conf_file" && \
    chown "$CRYPTOREST_USER.$CRYPTOREST_USER" "$conf_file" && \
    chmod 400 "$conf_file"

    sed -i "s/\[DOMAIN\]/$domain/g" "$conf_file" && \
    sed -i "s#\[ROOT_WWW\]#$CRYPTOREST_WWW_DOMAIN_DIR#g" "$conf_file" && \
    sed -i "s#\[LOG_WWW\]#$CRYPTOREST_NGINX_LOG_DOMAIN_DIR#g" "$conf_file" && \
    sed -i "s#\[SERVER_CIPHERS\]#$CRYPTOREST_OPENSSL_SERVER_CIPHERS#g" "$conf_file" && \
    sed -i "s#\[SSL_ECDH_CURVES\]#$CRYPTOREST_SSL_ECDH_CURVES#g" "$conf_file" && \
    sed -i "s#\[SSL_DOMAIN_DIR\]#$CRYPTOREST_SSL_DOMAIN_DIR#g" "$conf_file" && \
    sed -i "s#\[PUBLIC_KEY_PINS\]#$CRYPTOREST_PUBLIC_KEY_PINS#g" "$conf_file" && \
    sed -i "s#\[OCSP_HOST\]#$CRYPTOREST_OCSP_HOST#g" "$conf_file" && \
    sed -i "s#\[NGINX_CONF_DIR\]#$CRYPTOREST_NGINX_ETC_DIR#g" "$conf_file"
}

nginx_configs_define()
{
    local domain_prefix=''
    local template_file=''
    local conf_file=''

    echo ''

    for domain in $CRYPTOREST_DOMAINS; do
        domain_prefix="$(echo "$domain" | sed "s/$CRYPTOREST_DOMAIN//")"
        template_file="$CRYPTOREST_NGINX_ETC_DIR/$domain_prefix$CRYPTOREST_NGINX_CONF_TEMPLATE_FILE_EXT"
        conf_file="$CRYPTOREST_NGINX_ETC_DIR/$domain_prefix$CRYPTOREST_DOMAIN.conf"

        if [ -f "$template_file" ]; then
            nginx_log_dir_define "$domain" && \
            nginx_config_define "$domain" "$conf_file" "$template_file" && \
            nginx_links_define "$conf_file" && \

            echo "NGinx config and links has been defined for '$domain'"
        fi
    done

    echo ''
}
