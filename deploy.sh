#!/bin/bash
set -e

echo "============================================================"
echo "VIPL PLATFORM PRODUCTION DEPLOYMENT STARTED"
echo "============================================================"

if [ ! -f ".env" ]; then
  echo "ERROR: .env file not found."
  echo "Create it first:"
  echo "  cp .env.example .env"
  echo "  nano .env"
  exit 1
fi

if [ ! -f "docker-compose.yml" ]; then
  echo "ERROR: docker-compose.yml file not found."
  exit 1
fi

chmod +x *.sh 2>/dev/null || true
mkdir -p backups mysql-init

# Use docker directly if current user has permission, otherwise use sudo.
if docker ps >/dev/null 2>&1; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

COMPOSE="$DOCKER compose"

echo ""
echo "Checking Docker..."
$DOCKER --version

echo ""
echo "Checking Docker Compose..."
$COMPOSE version

echo ""
echo "Pulling latest images from Docker Hub..."
$COMPOSE pull

echo ""
echo "Starting MySQL and Redis first..."
$COMPOSE up -d mysql redis

echo ""
echo "Ensuring required MySQL schemas/databases exist..."
./ensure-databases.sh

echo ""
echo "Starting all VIPL services..."
$COMPOSE up -d

echo ""
echo "Waiting for services to initialize..."
sleep 25

echo ""
echo "Container status:"
$COMPOSE ps

echo ""
echo "Database table counts:"
MYSQL_ROOT_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' .env | cut -d '=' -f2-)
$DOCKER exec -i vipl-mysql mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<'SQL' || true
SELECT table_schema, COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema IN (
  'auth_db_v0',
  'cms_db_v0',
  'cms_transport_db_v0',
  'notification_db_v0'
)
GROUP BY table_schema;
SQL

echo ""
echo "Recent logs:"
$COMPOSE logs --tail=120

echo ""
echo "============================================================"
echo "VIPL PLATFORM DEPLOYMENT COMPLETED"
echo "============================================================"
echo "API Gateway: http://SERVER_IP:8080"
echo ""
echo "For DB access from your laptop:"
echo "ssh -L 3307:localhost:3306 USER@SERVER_IP"
echo "Then connect MySQL Workbench to 127.0.0.1:3307"
echo "============================================================"
