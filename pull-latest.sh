#!/bin/bash
set -e

./check-requirements.sh

if docker ps >/dev/null 2>&1; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

COMPOSE="$DOCKER compose"

echo "Pulling latest Docker Hub images..."
$COMPOSE pull

echo "Starting MySQL and Redis first..."
$COMPOSE up -d mysql redis

echo "Ensuring databases exist..."
./ensure-databases.sh

echo "Restarting all services with latest images..."
$COMPOSE up -d

echo "Status:"
$COMPOSE ps
