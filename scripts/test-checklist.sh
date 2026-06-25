#!/bin/bash
# =============================================================================
# Script de verificação do checklist de requisitos — Seção 3
# Execute após 'docker compose up --build' com os serviços rodando
# =============================================================================
set -e

echo "============================================"
echo "  CHECKLIST DE REQUISITOS — SEÇÃO 3"
echo "============================================"
echo ""

BASE_URL="http://localhost:8080"
PASS=0
FAIL=0

check() {
  if [ $1 -eq 0 ]; then
    echo "  ✅ $2"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $2"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== REQUISITOS TÉCNICOS ==="
echo ""

# Node.js 24+
NODE_VERSION=$(docker compose exec -T api node --version 2>/dev/null | grep -o 'v2[4-9]' || echo "")
[ -n "$NODE_VERSION" ] && check 0 "Node.js 24+ ($NODE_VERSION)" || check 1 "Node.js 24+"

# PostgreSQL 17+
PG_VERSION=$(docker compose exec -T postgres psql -U biblioteca -c "SELECT version();" 2>/dev/null | grep -o 'PostgreSQL 1[7-9]' || echo "")
[ -n "$PG_VERSION" ] && check 0 "PostgreSQL 17+ ($PG_VERSION)" || check 1 "PostgreSQL 17+"

# Express
DEPS=$(docker compose exec -T api cat package.json 2>/dev/null | grep '"express"' || echo "")
[ -n "$DEPS" ] && check 0 "Express presente em package.json" || check 1 "Express em package.json"

# Sequelize + pg
SEQ=$(docker compose exec -T api cat package.json 2>/dev/null | grep '"sequelize"' || echo "")
PG=$(docker compose exec -T api cat package.json 2>/dev/null | grep '"pg"' || echo "")
[ -n "$SEQ" ] && [ -n "$PG" ] && check 0 "Sequelize + pg driver" || check 1 "Sequelize + pg"

echo ""
echo "=== BANCO DE DADOS E MODELS ==="
echo ""

# 4+ tabelas
TABLES=$(docker compose exec -T postgres psql -U biblioteca -t -c "SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';" 2>/dev/null | tr -d ' ')
[ "$TABLES" -ge 4 ] 2>/dev/null && check 0 "No mínimo 4 tabelas ($TABLES encontradas)" || check 1 "4 tabelas mínimas"

# Tabela pivô
PIVOT=$(docker compose exec -T postgres psql -U biblioteca -t -c "SELECT count(*) FROM information_schema.tables WHERE table_name='book_authors';" 2>/dev/null | tr -d ' ')
[ "$PIVOT" -ge 1 ] 2>/dev/null && check 0 "Tabela pivô book_authors existe" || check 1 "Tabela pivô"

echo ""
echo "=== AUTENTICAÇÃO E ROTAS ==="
echo ""

# Login
TOKEN=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@biblioteca.local", "password": "123456"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
[ -n "$TOKEN" ] && check 0 "POST /login gera token JWT" || check 1 "POST /login"

# Rota protegida sem token → 401
STATUS_NO_AUTH=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/books")
[ "$STATUS_NO_AUTH" = "401" ] && check 0 "Rota protegida sem token retorna 401" || check 1 "401 sem token (retornou $STATUS_NO_AUTH)"

# Rota protegida com token → 200
STATUS_WITH_AUTH=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/books" -H "Authorization: Bearer $TOKEN")
[ "$STATUS_WITH_AUTH" = "200" ] && check 0 "Rota protegida com token retorna 200" || check 1 "200 com token (retornou $STATUS_WITH_AUTH)"

echo ""
echo "=== CRUD USERS ==="
# List
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/users" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /users → 200" || check 1 "GET /users ($S)"

# Get
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/users/1" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /users/1 → 200" || check 1 "GET /users/1 ($S)"

# Create
S=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/users" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Teste User","email":"teste_check@test.com","password":"123456"}')
[ "$S" = "201" ] && check 0 "POST /users → 201" || check 1 "POST /users ($S)"

# Update
S=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE_URL/users/1" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Admin Atualizado"}')
[ "$S" = "200" ] && check 0 "PUT /users/1 → 200" || check 1 "PUT /users/1 ($S)"

# Delete (delete the test user we created)
# First find the user id
TEST_USER_ID=$(curl -s "$BASE_URL/users" -H "Authorization: Bearer $TOKEN" | grep -o '"id":[0-9]*,"name":"Teste User"' | grep -o '[0-9]*' | head -1)
if [ -n "$TEST_USER_ID" ]; then
  S=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/users/$TEST_USER_ID" -H "Authorization: Bearer $TOKEN")
  [ "$S" = "204" ] && check 0 "DELETE /users/$TEST_USER_ID → 204" || check 1 "DELETE /users ($S)"
else
  check 1 "DELETE /users (não encontrou user de teste)"
fi

echo ""
echo "=== CRUD CATEGORIES ==="
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/categories" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /categories → 200" || check 1 "GET /categories ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/categories/1" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /categories/1 → 200" || check 1 "GET /categories/1 ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/categories" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Categoria Teste Check","description":"desc"}')
[ "$S" = "201" ] && check 0 "POST /categories → 201" || check 1 "POST /categories ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE_URL/categories/1" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"description":"Atualizada"}')
[ "$S" = "200" ] && check 0 "PUT /categories/1 → 200" || check 1 "PUT /categories/1 ($S)"

echo ""
echo "=== CRUD BOOKS ==="
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/books" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /books → 200" || check 1 "GET /books ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/books/1" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /books/1 → 200" || check 1 "GET /books/1 ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/books" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"title":"Livro Check","isbn":"0000000000001","publication_year":2025,"category_id":1}')
[ "$S" = "201" ] && check 0 "POST /books → 201" || check 1 "POST /books ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE_URL/books/1" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"publication_year":1900}')
[ "$S" = "200" ] && check 0 "PUT /books/1 → 200" || check 1 "PUT /books/1 ($S)"

echo ""
echo "=== CRUD AUTHORS ==="
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/authors" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /authors → 200" || check 1 "GET /authors ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/authors/1" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /authors/1 → 200" || check 1 "GET /authors/1 ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/authors" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Autor Check","nationality":"Brasileiro","birth_year":1990}')
[ "$S" = "201" ] && check 0 "POST /authors → 201" || check 1 "POST /authors ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$BASE_URL/authors/1" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nationality":"Brasileiro Atualizado"}')
[ "$S" = "200" ] && check 0 "PUT /authors/1 → 200" || check 1 "PUT /authors/1 ($S)"

echo ""
echo "=== TABELA PIVÔ (BOOK-AUTHORS) ==="
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/books/1/authors" -H "Authorization: Bearer $TOKEN")
[ "$S" = "200" ] && check 0 "GET /books/1/authors → 200" || check 1 "GET /books/1/authors ($S)"
# Criar novo vínculo (autor 5 ao livro 2, se não existir)
S=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/books/2/authors/5" -H "Authorization: Bearer $TOKEN")
([ "$S" = "201" ] || [ "$S" = "409" ]) && check 0 "POST /books/2/authors/5 → $S" || check 1 "POST /books/2/authors/5 ($S)"
S=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/books/2/authors/5" -H "Authorization: Bearer $TOKEN")
[ "$S" = "204" ] && check 0 "DELETE /books/2/authors/5 → 204" || check 1 "DELETE /books/2/authors/5 ($S)"

echo ""
echo "=== DOCKER E INFRAESTRUTURA ==="

# Nginx acessível em 8080
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/health")
[ "$S" = "200" ] && check 0 "Nginx acessível em localhost:8080" || check 1 "Nginx em 8080 ($S)"

# API NÃO acessível em 3000 diretamente
S=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://localhost:3000/health" 2>/dev/null || echo "000")
[ "$S" = "000" ] && check 0 "API NÃO acessível diretamente em localhost:3000 (correto)" || check 1 "API acessível em 3000 (deveria estar bloqueada, retornou $S)"

# Swagger
S=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api-docs/")
([ "$S" = "200" ] || [ "$S" = "301" ]) && check 0 "Swagger acessível em /api-docs ($S)" || check 1 "Swagger ($S)"

# Health
HEALTH=$(curl -s "$BASE_URL/health")
echo "$HEALTH" | grep -q '"status":"ok"' && check 0 "Health check retorna status ok" || check 1 "Health check"

echo ""
echo "============================================"
echo "  RESULTADO FINAL"
echo "  ✅ Passou: $PASS"
echo "  ❌ Falhou: $FAIL"
echo "============================================"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
