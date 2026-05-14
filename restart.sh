#!/bin/bash
set -e
docker compose restart
docker compose ps
