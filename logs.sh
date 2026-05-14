#!/bin/bash
SERVICE=$1
if [ -z "$SERVICE" ]; then
  docker compose logs -f --tail=200
else
  docker compose logs -f --tail=200 "$SERVICE"
fi
