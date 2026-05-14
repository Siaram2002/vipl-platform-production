# VIPL Platform Production Deployment

This folder is safe for GitHub. It does not contain the real `.env`.

## Does the server need Docker?

Yes. Your server must have Docker Engine and Docker Compose plugin because `docker-compose.yml` pulls and runs your Docker Hub images.

Images used:

- badulla2003/vipl-eureka-server:1.0.0
- badulla2003/vipl-api-gateway:1.0.0
- badulla2003/vipl-auth-service:1.0.0
- badulla2003/vipl-cms-service:1.0.0
- badulla2003/vipl-cms-transport-service:1.0.0
- badulla2003/vipl-notification-service:1.0.0

## First server setup

```bash
sudo mkdir -p /opt/vipl-platform
sudo chown -R $USER:$USER /opt/vipl-platform
cd /opt/vipl-platform
```

Clone this repo, then:

```bash
chmod +x *.sh
./first-time-setup.sh
nano .env
./deploy.sh
```

## Database safety

The SQL uses `CREATE DATABASE IF NOT EXISTS`, so it will not delete existing databases.

The scripts do not use `docker compose down -v`, so MySQL/upload volumes are preserved.

## DB connection from your laptop

```bash
ssh -L 3307:localhost:3306 USER@SERVER_IP
```

Then connect MySQL Workbench to:

```text
127.0.0.1:3307
```

## Updated Database Auto-Creation Flow

This package includes `ensure-databases.sh`.

Why this is needed:

MySQL Docker init scripts under `/docker-entrypoint-initdb.d` run only when the MySQL data volume is initialized for the first time. If the volume already exists, MySQL does not rerun those SQL files. To avoid manual database creation, `deploy.sh` now does this every deployment:

```text
1. Start mysql and redis first
2. Wait until MySQL is ready
3. Run ensure-databases.sh
4. Create missing schemas safely:
   CREATE DATABASE IF NOT EXISTS auth_db_v0
   CREATE DATABASE IF NOT EXISTS cms_db_v0
   CREATE DATABASE IF NOT EXISTS cms_transport_db_v0
   CREATE DATABASE IF NOT EXISTS notification_db_v0
5. Start all services
6. Spring Boot with ddl-auto=update creates missing tables
```

This is safe for existing databases and tables. It does not delete data.

Manual check:

```bash
./ensure-databases.sh
```

Check table counts:

```bash
MYSQL_ROOT_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' .env | cut -d '=' -f2-)

sudo docker exec -i vipl-mysql mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<'SQL'
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
```
