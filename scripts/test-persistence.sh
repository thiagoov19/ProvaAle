#!/bin/bash
# =============================================================================
# Script de teste de persistência — Seção 2 do prompt de avaliação
# Execute este script no diretório raiz do projeto (onde está o docker-compose.yml)
# =============================================================================
set -e

echo "============================================"
echo "  ROTEIRO DE TESTE DE PERSISTÊNCIA"
echo "============================================"
echo ""

# Passo 1: Subida limpa
echo ">>> PASSO 1: docker compose down -v (limpeza total)"
docker compose down -v --remove-orphans 2>/dev/null || true
echo ""

echo ">>> PASSO 1b: docker compose up --build (subida limpa, banco vazio)"
docker compose up -d --build
echo "Aguardando serviços ficarem saudáveis..."
sleep 15

echo ""
echo ">>> Status dos containers:"
docker compose ps
echo ""

# Passo 2: Login com usuário seed
echo ">>> PASSO 2: Login com usuário seed (admin@biblioteca.local)"
TOKEN=$(curl -s -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@biblioteca.local", "password": "123456"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "❌ ERRO: Não foi possível obter token de login!"
  echo "Verifique se o seed foi executado corretamente."
  exit 1
fi
echo "✅ Token obtido: ${TOKEN:0:30}..."
echo ""

# Passo 3: Criar livro novo
echo ">>> PASSO 3: Criar livro novo via POST /books"
NOVO_LIVRO=$(curl -s -X POST http://localhost:8080/books \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "Livro Teste Persistencia", "isbn": "9999999999999", "publication_year": 2026, "category_id": 1}')
echo "Resposta: $NOVO_LIVRO"

BOOK_ID=$(echo "$NOVO_LIVRO" | grep -o '"id":[0-9]*' | head -1 | cut -d: -f2)
echo "ID do livro criado: $BOOK_ID"

# Vincular autor ao livro novo
echo ""
echo ">>> PASSO 3b: Vincular autor (id=1) ao livro novo"
curl -s -X POST "http://localhost:8080/books/$BOOK_ID/authors/1" \
  -H "Authorization: Bearer $TOKEN"
echo ""

# Passo 4: Verificar que o livro aparece
echo ""
echo ">>> PASSO 4: GET /books — verificar que o livro novo aparece"
BOOKS_COUNT=$(curl -s http://localhost:8080/books \
  -H "Authorization: Bearer $TOKEN" | grep -o '"Livro Teste Persistencia"' | wc -l)

if [ "$BOOKS_COUNT" -ge 1 ]; then
  echo "✅ Livro 'Livro Teste Persistencia' encontrado na listagem!"
else
  echo "❌ ERRO: Livro criado não aparece na listagem!"
  exit 1
fi
echo ""

# Passo 5: docker compose down (sem -v)
echo ">>> PASSO 5: docker compose down (sem -v — preserva volume)"
docker compose down
echo ""

# Passo 6: docker compose up (sem --build, sem -v)
echo ">>> PASSO 6: docker compose up (sem --build, sem -v)"
docker compose up -d
echo "Aguardando serviços ficarem saudáveis..."
sleep 15
docker compose ps
echo ""

# Passo 7: Verificar persistência
echo ">>> PASSO 7: GET /books — verificar que livro criado ainda está lá"
TOKEN2=$(curl -s -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@biblioteca.local", "password": "123456"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

BOOKS_AFTER=$(curl -s http://localhost:8080/books \
  -H "Authorization: Bearer $TOKEN2" | grep -o '"Livro Teste Persistencia"' | wc -l)

if [ "$BOOKS_AFTER" -ge 1 ]; then
  echo "✅✅ PERSISTÊNCIA CONFIRMADA! Livro criado via API sobreviveu ao restart!"
  echo "    O seed NÃO foi reexecutado (dados preservados)."
else
  echo "❌❌ FALHA DE PERSISTÊNCIA! Livro desapareceu após restart!"
  echo "    O seed pode estar sendo reexecutado indevidamente."
  exit 1
fi
echo ""

# Passo 8: Testar reset com -v
echo ">>> PASSO 8: docker compose down -v (remove volumes)"
docker compose down -v
echo ""

echo ">>> PASSO 8b: docker compose up --build (subida com banco vazio)"
docker compose up -d --build
sleep 15

TOKEN3=$(curl -s -X POST http://localhost:8080/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@biblioteca.local", "password": "123456"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

BOOKS_RESET=$(curl -s http://localhost:8080/books \
  -H "Authorization: Bearer $TOKEN3" | grep -o '"Livro Teste Persistencia"' | wc -l)

if [ "$BOOKS_RESET" -eq 0 ]; then
  echo "✅ Após down -v + up, banco voltou ao estado inicial (apenas seed)."
  echo "   Livro de teste não existe mais (comportamento esperado)."
else
  echo "❌ ERRO: Livro de teste ainda existe após down -v!"
  exit 1
fi

echo ""
echo "============================================"
echo "  ✅ TODOS OS TESTES DE PERSISTÊNCIA PASSARAM!"
echo "============================================"
echo ""
echo "Resumo:"
echo "  1. Banco vazio → seed executa → dados fictícios inseridos ✅"
echo "  2. Dados criados via API persistem após restart (down + up) ✅"
echo "  3. down -v reseta o banco → seed executa novamente ✅"
echo ""

# Limpar
docker compose down
