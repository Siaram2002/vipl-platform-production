#!/bin/bash
set -e

echo "============================================================"
echo "VIPL PLATFORM FIRST-TIME SERVER SETUP"
echo "============================================================"

chmod +x *.sh 2>/dev/null || true

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing Docker..."
  ./install-docker-ubuntu.sh
else
  echo "Docker already installed."
  docker --version || sudo docker --version
fi

if ! docker compose version >/dev/null 2>&1 && ! sudo docker compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin not found. Installing Docker..."
  ./install-docker-ubuntu.sh
else
  echo "Docker Compose plugin already installed."
  docker compose version || sudo docker compose version
fi

if [ ! -f ".env" ]; then
  echo "Creating .env from .env.example..."
  cp .env.example .env
  echo ""
  echo "IMPORTANT: edit .env and add real passwords/secrets:"
  echo "  nano .env"
else
  echo ".env already exists."
fi

echo ""
echo "First-time setup completed."
echo "Next:"
echo "  nano .env"
echo "  ./deploy.sh"
