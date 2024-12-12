# Initialize environment variables
pap_init() {
    export APP_DOMAIN=${APP_DOMAIN:-"cryptochromatic.net"}
    export APP_SLUG=${APP_SLUG:-"pap"}
    export STATIC_PATH=${STATIC_PATH:-"$APP_SLUG/static"}
    export API_PATH=${API_PATH:-"$APP_SLUG/api"}
    export FALLBACK_PATH=${FALLBACK_PATH:-"$APP_SLUG/fallback"}
    export STATIC_ROOT=${STATIC_ROOT:-"/var/www/html/$STATIC_PATH"}
    export APP_HOST=${APP_HOST:-"127.0.0.1"}
    export APP_PORT=${APP_PORT:-3000}
    export NGINX_CONFIG=${NGINX_CONFIG:-"/etc/nginx/sites-enabled/$APP_DOMAIN"}
    export NGINX_SNIPPET=${NGINX_SNIPPET:-"/etc/nginx/snippets/$APP_SLUG.conf"}

    echo "Environment initialized:"
    echo "  APP_DOMAIN=$APP_DOMAIN"
    echo "  APP_SLUG=$APP_SLUG"
    echo "  STATIC_PATH=$STATIC_PATH"
    echo "  API_PATH=$API_PATH"
    echo "  FALLBACK_PATH=$FALLBACK_PATH"
    echo "  STATIC_ROOT=$STATIC_ROOT"
    echo "  APP_HOST=$APP_HOST"
    echo "  APP_PORT=$APP_PORT"
    echo "  NGINX_CONFIG=$NGINX_CONFIG"
    echo "  NGINX_SNIPPET=$NGINX_SNIPPET"
}

# Check if server_name matches
_pap_check_server_name() {
    local config_file="$1"
    local server_name="$2"

    if grep -q "server_name $server_name;" "$config_file"; then
        return 0 # Found
    else
        return 1 # Not found
    fi
}

# Check if location path exists
_pap_check_location_path() {
    local config_file="$1"
    local path="$2"

    if grep -q "location /$path/" "$config_file"; then
        return 0 # Found
    else
        return 1 # Not found
    fi
}

# Add a location block
_pap_add_location_block() {
    local config_file="$1"
    local path="$2"
    local snippet="$3"

    echo "Adding location block for path '/$path/'..."
    sudo sed -i "/server_name $APP_DOMAIN;/a\ \n    location /$path/ {\n        include $snippet;\n    }\n" "$config_file"
    echo "Location block for '/$path/' added."
}

# Remove a location block
_pap_remove_location_block() {
    local config_file="$1"
    local path="$2"

    echo "Removing location block for path '/$path/'..."
    sudo sed -i "/location \/$path\/ {/,/}/d" "$config_file"
    echo "Location block for '/$path/' removed."
}

# Generate NGINX snippet for static and proxy paths
pap_generate_snippet() {
    echo "Generating NGINX snippet at $NGINX_SNIPPET..."
    sudo mkdir -p "$(dirname $NGINX_SNIPPET)"
    sudo cat > "$NGINX_SNIPPET" <<EOL
# Serve static files for $APP_SLUG
location /$STATIC_PATH/ {
    root $STATIC_ROOT;
    index index.html;
    try_files \$uri \$uri/ =404;
}

# Proxy API requests for $APP_SLUG
location /$API_PATH/ {
    proxy_pass http://$APP_HOST:$APP_PORT;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}

# Fallback for undefined paths
location /$FALLBACK_PATH/ {
    proxy_pass http://$APP_HOST:$APP_PORT;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
EOL
    echo "NGINX snippet generated."
}

# Modify NGINX configuration to add or warn about location blocks
pap_modify_config() {
    echo "Modifying NGINX configuration at $NGINX_CONFIG..."
    if [ ! -f "$NGINX_CONFIG" ]; then
        echo "Error: Configuration file $NGINX_CONFIG does not exist."
        return 1
    fi

    # Check if server_name matches
    if ! _pap_check_server_name "$NGINX_CONFIG" "$APP_DOMAIN"; then
        echo "Error: server_name $APP_DOMAIN not found in $NGINX_CONFIG."
        return 1
    fi

    # Check and add location blocks
    for path in "$STATIC_PATH" "$API_PATH" "$FALLBACK_PATH"; do
        if _pap_check_location_path "$NGINX_CONFIG" "$path"; then
            echo "Warning: Location '/$path/' already defined."
        else
            _pap_add_location_block "$NGINX_CONFIG" "$path" "$NGINX_SNIPPET"
        fi
    done

    echo "NGINX configuration updated for $APP_DOMAIN."
    pap_reload_nginx
}

# Apply configurations
pap_apply() {
    pap_generate_snippet
    pap_modify_config
    echo "PAP configuration applied."
}

# Revert configurations
pap_revert() {
    echo "Reverting PAP configuration for $APP_DOMAIN..."

    # Remove location blocks
    for path in "$STATIC_PATH" "$API_PATH" "$FALLBACK_PATH"; do
        _pap_remove_location_block "$NGINX_CONFIG" "$path"
    done

    # Remove snippet
    sudo rm -f "$NGINX_SNIPPET"
    echo "Snippet removed at $NGINX_SNIPPET."

    # Reload NGINX
    pap_reload_nginx
    echo "PAP configuration reverted."
}

# Reload NGINX
pap_reload_nginx() {
    echo "Reloading NGINX..."
    sudo nginx -t && sudo systemctl reload nginx
    echo "NGINX reloaded."
}
