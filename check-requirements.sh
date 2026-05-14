#!/bin/bash
set -e

echo "Checking Docker..."

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Run:"
  echo "  ./install-docker-ubuntu.sh"
  exit 1
fi

if docker ps >/dev/null 2>&1; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

$DOCKER --version

echo "Checking Docker Compose plugin..."

if ! $DOCKER compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin is not installed. Run:"
  echo "  ./install-docker-ubuntu.sh"
  exit 1
fi

$DOCKER compose version

if [ ! -f ".env" ]; then
  echo ".env file is missing."
  echo "Run:"
  echo "  cp .env.example .env"
  echo "  nano .env"
  exit 1
fi

if [ ! -f "docker-compose.yml" ]; then
  echo "docker-compose.yml is missing."
  exit 1
fi

echo "Requirements OK."
