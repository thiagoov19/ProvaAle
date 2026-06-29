# Biblioteca API — Infraestrutura Docker

## 1. Identificação do Projeto

### Título

**Sistema de Biblioteca API**

### Descrição

O projeto consiste em uma API REST para gerenciamento de uma biblioteca. A aplicação permite autenticação de usuários com JWT, cadastro e consulta de livros, autores, categorias e relacionamentos entre livros e autores.

A infraestrutura foi construída utilizando containers Docker, com separação entre aplicação, banco de dados, cache, proxy reverso e migrations.

### Caminho escolhido

O projeto segue a **Opção A — Docker / Orquestração Local**.

A infraestrutura local foi construída utilizando Docker e Docker Compose, com múltiplos containers, redes isoladas, volume persistente e Nginx como ponto de entrada da aplicação.

---

## 2. Pré-requisitos

Para executar o projeto, é necessário possuir as seguintes ferramentas instaladas:

* Docker Desktop;
* Docker Compose;
* WSL2 habilitado no Windows;
* Git;
* Navegador web;
* VS Code ou outro editor de código.

### Configurações iniciais necessárias

Antes de subir o projeto, é recomendado criar o arquivo `.env` com base no `.env.example`.

No Windows CMD:

```cmd
copy .env.example .env
```

No Linux, WSL ou Git Bash:

```bash
cp .env.example .env
```

O projeto também possui valores padrão no `docker-compose.yml`, então pode funcionar mesmo sem criar manualmente o `.env`.

---

## 3. Guia de Instalação e Execução — How to Up

### 1. Clonar o repositório

```bash
git clone https://github.com/thiagoov19/ProvaAle.git
```

Entrar na pasta do projeto:

```bash
cd ProvaAle
```

---

### 2. Subir a infraestrutura completa com Docker

Execute o comando:

```bash
docker compose up -d --build
```

Esse comando realiza:

* build da imagem da API;
* criação das redes Docker;
* criação do volume do PostgreSQL;
* subida do container Nginx;
* subida do container da API Node.js;
* subida do container PostgreSQL;
* subida do container Redis;
* execução do container de migrations.

---

### 3. Verificar containers em execução

```bash
docker ps
```

O esperado é visualizar os containers principais:

```text
biblioteca_nginx
biblioteca_api
biblioteca_postgres
biblioteca_redis
```

O container de migrations pode não aparecer no `docker ps`, pois ele executa as migrations e finaliza.

Para visualizar todos os containers, inclusive os finalizados:

```bash
docker compose ps -a
```

O container `biblioteca_migrate` deve aparecer como:

```text
Exited (0)
```

Isso significa que as migrations foram executadas com sucesso.

---

## 4. Containers utilizados no projeto

| Container             | Função                                              |
| --------------------- | --------------------------------------------------- |
| `biblioteca_nginx`    | Proxy reverso e ponto de entrada da aplicação       |
| `biblioteca_api`      | API Node.js com Express                             |
| `biblioteca_postgres` | Banco de dados PostgreSQL                           |
| `biblioteca_redis`    | Serviço Redis utilizado como cache/serviço auxiliar |
| `biblioteca_migrate`  | Container responsável por executar as migrations    |

---

## 5. Planta Arquitetural do Sistema

A arquitetura do projeto funciona da seguinte forma:

```text
Usuário
   ↓
localhost:8080
   ↓
Nginx
   ↓
API Node.js
   ↓
PostgreSQL
```

O Nginx é o único serviço exposto externamente pela porta `8080`.

A API, o PostgreSQL e o Redis ficam na rede interna do Docker, sem exposição direta para o usuário externo.

---

## 6. Acessos da Aplicação

### API via Nginx

```text
http://localhost:8080
```

### Swagger

```text
http://localhost:8080/api-docs
```

### Healthcheck

```text
http://localhost:8080/health
```

---

## 7. Login e uso do token JWT

Para acessar as rotas protegidas, é necessário realizar login.

### Rota de login

```http
POST http://localhost:8080/login
```

Body:

```json
{
  "email": "admin@biblioteca.local",
  "password": "123456"
}
```

A API retornará um token JWT:

```json
{
  "token": "TOKEN_GERADO_AQUI"
}
```

Nas requisições HTTP, o token deve ser enviado no header:

```http
Authorization: Bearer SEU_TOKEN_AQUI
```

No Swagger, clique em **Authorize** e cole apenas o token puro, sem escrever `Bearer`, pois o Swagger já está configurado como Bearer Auth.

---

## 8. Execução das migrations

As migrations são executadas automaticamente pelo container `biblioteca_migrate` durante a subida do ambiente.

Para verificar os logs das migrations:

```bash
docker compose logs migrate
```

Também é possível visualizar o status do container:

```bash
docker compose ps -a
```

O status esperado é:

```text
biblioteca_migrate   Exited (0)
```

Isso indica que o container executou a tarefa corretamente e foi encerrado com sucesso.

---

## 9. Comandos para evidências de execução

### Containers ativos

```bash
docker ps
```

### Status completo dos serviços

```bash
docker compose ps -a
```

### Logs da API

```bash
docker compose logs api
```

### Logs do Nginx

```bash
docker compose logs nginx
```

### Logs do PostgreSQL

```bash
docker compose logs postgres
```

### Logs do Redis

```bash
docker compose logs redis
```

### Logs das migrations

```bash
docker compose logs migrate
```

---

## 10. Rede Docker

Para listar as redes Docker:

```bash
docker network ls
```

Para inspecionar a rede backend do projeto:

```bash
docker network inspect biblioteca-api-corrigida_backend_network
```

Caso o nome da rede seja diferente, utilize `docker network ls` para identificar o nome correto.

A rede Docker permite que os containers se comuniquem internamente usando o nome do serviço, sem necessidade de IP fixo.

---

## 11. Volume persistente do PostgreSQL

Para listar os volumes:

```bash
docker volume ls
```

Para inspecionar o volume do PostgreSQL:

```bash
docker volume inspect biblioteca-api-corrigida_biblioteca_postgres_data
```

Caso o nome do volume seja diferente, utilize `docker volume ls` para identificar o nome correto.

O volume é responsável por manter os dados do banco mesmo após parar e subir novamente os containers.

---

## 12. Prova de Conceito — Persistência

Para provar a persistência dos dados:

### 1. Criar um livro pelo Swagger

Acesse:

```text
http://localhost:8080/api-docs
```

Faça login, autorize o token e crie um livro na rota:

```http
POST /books
```

Exemplo:

```json
{
  "title": "Livro Persistencia Evidencia",
  "isbn": "9788888888888",
  "publication_year": 2026,
  "category_id": 1
}
```

---

### 2. Buscar o livro criado

Use:

```http
GET /books
```

ou:

```http
GET /books/{id}
```

Confirme que o livro foi salvo.

---

### 3. Parar os containers sem apagar o volume

```bash
docker compose down
```

Esse comando remove os containers, mas mantém os volumes.

---

### 4. Subir novamente

```bash
docker compose up -d
```

---

### 5. Buscar o mesmo livro novamente

Acesse novamente o Swagger, faça login, autorize o token e busque o mesmo livro.

Se o livro continuar aparecendo, significa que os dados persistiram corretamente no volume do PostgreSQL.

---

## 13. Prova de Conceito — Segurança

A aplicação deve ser acessada externamente pelo Nginx:

```text
http://localhost:8080/health
```

Esse acesso deve funcionar.

A API Node.js não deve estar exposta diretamente pela porta 3000:

```text
http://localhost:3000/health
```

Esse acesso deve falhar, pois a API está protegida na rede interna do Docker.

O PostgreSQL e o Redis também não são acessados diretamente pelo navegador. Eles ficam disponíveis apenas dentro da rede Docker para comunicação com a API.

---

## 14. Logs do build e execução

Durante a execução do comando:

```bash
docker compose up -d --build
```

O Docker realiza o build da imagem da API e cria os containers necessários.

Para registrar evidência do build e da execução, devem ser capturados prints do terminal mostrando:

* build da imagem;
* criação das redes;
* criação do volume;
* containers saudáveis;
* container de migration finalizado com sucesso.

---

## 15. Parar e limpar o ambiente

### Parar sem apagar os dados

```bash
docker compose down
```

Esse comando para os containers, mas mantém o volume do PostgreSQL.

### Parar e apagar tudo, incluindo dados do banco

```bash
docker compose down -v --remove-orphans
```

Atenção: o parâmetro `-v` apaga os volumes Docker. Portanto, ele remove os dados persistidos do banco.

---

## 16. Video narrado

O projeto também possui um vídeo narrado demonstrando:

* inicialização do ambiente;
* containers em execução;
* acesso ao Swagger;
* login com JWT;
* rota protegida funcionando;
* CRUD básico;
* rede Docker;
* volume do PostgreSQL;
* teste de persistência;
* segurança da aplicação com acesso externo apenas pelo Nginx.

---

## 17. Resumo

Este projeto atende aos requisitos de infraestrutura utilizando Docker e Docker Compose. A aplicação possui containers separados, rede interna, volume persistente, Nginx como proxy reverso, migrations automatizadas, autenticação JWT e documentação Swagger.

O ambiente pode ser iniciado com:

```bash
docker compose up -d --build
```

E acessado em:

```text
http://localhost:8080/api-docs
```
