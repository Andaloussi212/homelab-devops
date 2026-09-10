#!/bin/bash

set -Eeuo pipefail

# ==============================
# Configuration
# ==============================

BACKUP_ROOT="/mnt/backup/backups/nextcloud"
NEXTCLOUD_HTML="/mnt/backup/nextcloud/html"
NEXTCLOUD_DATA="/mnt/backup/nextcloud/data"
NEXTCLOUD_COMPOSE="/home/zayd/nextcloud/compose.yml"

APP_CONTAINER="nextcloud-app"
DB_CONTAINER="nextcloud-db"

DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
BACKUP_DIR="${BACKUP_ROOT}/${DATE}"

MAINTENANCE_ENABLED=false

# ==============================
# Fonctions
# ==============================

cleanup() {
    if [ "$MAINTENANCE_ENABLED" = true ]; then
        echo "[INFO] Désactivation du mode maintenance..."
        docker exec -u www-data "$APP_CONTAINER" \
            php occ maintenance:mode --off || true
    fi
}

trap cleanup EXIT

echo "========================================"
echo "Sauvegarde Nextcloud : $DATE"
echo "========================================"

# Création du dossier de sauvegarde
mkdir -p "$BACKUP_DIR"

# ==============================
# Mode maintenance
# ==============================

echo "[INFO] Activation du mode maintenance..."

docker exec -u www-data "$APP_CONTAINER" \
    php occ maintenance:mode --on

MAINTENANCE_ENABLED=true

# ==============================
# Dump MariaDB
# ==============================

echo "[INFO] Sauvegarde de la base MariaDB..."

docker exec "$DB_CONTAINER" sh -c \
    'mariadb-dump --single-transaction --quick --lock-tables=false -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' \
    > "$BACKUP_DIR/nextcloud-db.sql"

# ==============================
# Sauvegarde de Nextcloud
# ==============================

echo "[INFO] Sauvegarde des fichiers Nextcloud..."

mkdir -p "$BACKUP_DIR/html"
mkdir -p "$BACKUP_DIR/data"

rsync -a \
    --exclude='data/' \
    "$NEXTCLOUD_HTML/" \
    "$BACKUP_DIR/html/"

rsync -a \
    "$NEXTCLOUD_DATA/" \
    "$BACKUP_DIR/data/"

# Sauvegarde du fichier Docker Compose
if [ -f "$NEXTCLOUD_COMPOSE" ]; then
    cp "$NEXTCLOUD_COMPOSE" "$BACKUP_DIR/compose.yml"
fi

# ==============================
# Fin maintenance
# ==============================

echo "[INFO] Désactivation du mode maintenance..."

docker exec -u www-data "$APP_CONTAINER" \
    php occ maintenance:mode --off

MAINTENANCE_ENABLED=false

# ==============================
# Rotation
# ==============================

echo "[INFO] Suppression des sauvegardes de plus de 7 jours..."

find "$BACKUP_ROOT" \
    -mindepth 1 \
    -maxdepth 1 \
    -type d \
    -mtime +7 \
    -exec rm -rf {} \;

# ==============================
# Résultat
# ==============================

echo
echo "[OK] Sauvegarde terminée :"
echo "$BACKUP_DIR"
echo

du -sh "$BACKUP_DIR"

echo "========================================"
