#!/bin/bash
set -e

BACKUP_DIR="./backups"
DATE=$(date +"%Y%m%d_%H%M%S")
mkdir -p "$BACKUP_DIR"

MYSQL_ROOT_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' .env | cut -d '=' -f2-)

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "MYSQL_ROOT_PASSWORD not found in .env"
  exit 1
fi

docker exec vipl-mysql sh -c "mysqldump -uroot -p\"$MYSQL_ROOT_PASSWORD\" --databases auth_db_v0 cms_db_v0 cms_transport_db_v0 notification_db_v0" > "$BACKUP_DIR/vipl_mysql_backup_$DATE.sql"

echo "Backup created: $BACKUP_DIR/vipl_mysql_backup_$DATE.sql"
