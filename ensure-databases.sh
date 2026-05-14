#!/bin/bash
set -e

echo "============================================================"
echo "ENSURING VIPL MYSQL DATABASES EXIST"
echo "============================================================"

if [ ! -f ".env" ]; then
  echo "ERROR: .env file not found."
  echo "Create it first: cp .env.example .env"
  exit 1
fi

MYSQL_ROOT_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' .env | cut -d '=' -f2-)

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "ERROR: MYSQL_ROOT_PASSWORD not found in .env"
  exit 1
fi

# Use docker directly if current user has permission, otherwise use sudo.
if docker ps >/dev/null 2>&1; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

echo "Waiting for MySQL container to be ready..."

until $DOCKER exec vipl-mysql mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent >/dev/null 2>&1; do
  echo "Waiting for MySQL..."
  sleep 5
done

echo "MySQL is ready."

echo "Creating missing databases safely..."

$DOCKER exec -i vipl-mysql mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<'SQL'
CREATE DATABASE IF NOT EXISTS auth_db_v0
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS cms_db_v0
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS cms_transport_db_v0
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS notification_db_v0
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

SHOW DATABASES;
SQL

echo "VIPL MySQL databases are ready."
echo "============================================================"
