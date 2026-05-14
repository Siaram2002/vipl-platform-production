#!/bin/bash
set -e
docker compose down --remove-orphans
echo "Stopped without deleting volumes."
