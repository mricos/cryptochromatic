# Common variables for reuse
SOURCE="/var/www/html/"
EXCLUDE_LIST=("node_modules" ".git" "cache")
EXCLUDE_ARGS=()
for item in "${EXCLUDE_LIST[@]}"; do
    EXCLUDE_ARGS+=(--exclude="$item")
done

# Local backup function
sync_local_backup() {
    local destination="/backup/html/cc.net"

    # Perform local rsync backup
    rsync -avh "${EXCLUDE_ARGS[@]}" "$SOURCE" "$destination"

    echo "Local backup of $SOURCE completed to $destination, ignoring: ${EXCLUDE_LIST[*]}"
}

# Remote backup initiated from source server
sync_remote_push() {
    local destination_user="mricos"
    local destination_host="kingdel"
    local destination_path="/home/mricos/backups"

    # Push data to remote server
    rsync -avh -e "ssh" "${EXCLUDE_ARGS[@]}" "$SOURCE" "${destination_user}@${destination_host}:${destination_path}/"

    echo "Remote push backup of $SOURCE completed to ${destination_user}@${destination_host}:${destination_path}, ignoring: ${EXCLUDE_LIST[*]}"
}

# Remote backup pulled from the destination server
sync_remote_pull() {
    local source_host="do5"
    local destination="/home/mricos/backups"

    # Pull data from remote server
    rsync -avh -e "ssh" "${EXCLUDE_ARGS[@]}" "root@${source_host}:${SOURCE}" "$destination"

    echo "Remote pull backup from ${source_host}:${SOURCE} completed to $destination, ignoring: ${EXCLUDE_LIST[*]}"
}

# Backup using reverse SSH tunnel
sync_reverse_tunnel() {
    local destination_user="mricos"
    local destination_path="/home/mricos/backups"

    # Ensure reverse tunnel is set up
    echo "Setting up reverse SSH tunnel..."
    ssh -fN -R 2222:localhost:22 root@do5

    # Use the reverse tunnel to send files
    rsync -avh -e "ssh -p 2222" "${EXCLUDE_ARGS[@]}" "$SOURCE" "${destination_user}@localhost:${destination_path}/"

    echo "Backup of $SOURCE via reverse SSH tunnel completed to ${destination_user}@localhost:${destination_path}, ignoring: ${EXCLUDE_LIST[*]}"
}

# Local backup for reverse-proxy-related files
sync_reverse_proxy_backup() {
    local nginx_config="/etc/nginx/sites-available/"
    local destination="/backup/nginx"

    # Perform rsync for reverse proxy configurations
    rsync -avh "${EXCLUDE_ARGS[@]}" "$nginx_config" "$destination"

    echo "Backup of NGINX reverse proxy configuration completed to $destination, ignoring: ${EXCLUDE_LIST[*]}"
}

