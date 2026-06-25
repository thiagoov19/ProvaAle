#!/bin/bash
set -e
echo "Subindo Biblioteca API..."
docker compose up -d --build
echo ""
echo "Aguardando serviços..."
sleep 5
docker compose ps
echo ""
echo "API disponível em: http://localhost:8080"
echo "Swagger:           http://localhost:8080/api-docs"
echo "Health:            http://localhost:8080/health"
