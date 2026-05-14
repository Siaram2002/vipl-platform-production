#!/bin/bash
docker compose ps
echo ""
docker volume ls | grep vipl || true
echo ""
docker images | grep badulla2003 || true
