# Sistema de Biblioteca API

API REST desenvolvida para gerenciamento de uma biblioteca, utilizando Node.js, Express, PostgreSQL, Sequelize, JWT, Swagger e Docker.

O projeto possui autenticação com JWT, rotas protegidas, migrations, documentação Swagger e execução completa via Docker.

---

## Tecnologias utilizadas

* Node.js
* Express
* PostgreSQL
* Sequelize
* JWT
* Bcrypt
* Swagger
* Docker
* Docker Compose
* Nginx
* Redis

---

## Containers utilizados no projeto

O projeto utiliza os seguintes containers:

| Container             | Função                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------- |
| `biblioteca_nginx`    | Servidor Nginx responsável por receber as requisições na porta 8080 e encaminhar para a API |
| `biblioteca_api`      | Container da aplicação Node.js/Express                                                      |
| `biblioteca_postgres` | Banco de dados PostgreSQL                                                                   |
| `biblioteca_redis`    | Serviço Redis utilizado como cache/infraestrutura auxiliar                                  |
| `biblioteca_migrate`  | Container responsável por executar as migrations do banco de dados                          |

---

## Estrutura principal do projeto

```text
biblioteca-api/
├── src/
│   ├── app.js
│   ├── server.js
│   ├── command.js
│   ├── database/
│   │   ├── migrate.js
│   │   ├── run-sql-seed.js
│   │   └── migrations/
│   ├── models/
│   ├── controllers/
│   ├── routes/
│   └── middlewares/
├── scripts/
│   └── seed.sql
├── docker-compose.yml
├── Dockerfile
├── .env
├── .env.example
└── README.md
```

---

## Como executar o projeto com Docker

### 1. Abrir o Docker Desktop

Antes de executar o projeto, abra o Docker Desktop e aguarde ele iniciar completamente.

---

### 2. Abrir o terminal na pasta do projeto

No VS Code, abra a pasta do projeto e abra o terminal.

Confirme que você está na pasta onde existe o arquivo:

```bash
docker-compose.yml
```

Para verificar os arquivos da pasta, use:

```bash
dir
```

Ou, no Linux/WSL:

```bash
ls
```

---

### 3. Subir os containers

Execute o comando:

```bash
docker compose up -d --build
```

Esse comando irá:

* construir a imagem da API;
* criar o container da API;
* criar o container do PostgreSQL;
* criar o container do Redis;
* criar o container do Nginx;
* executar o container de migrations.

---

### 4. Verificar se os containers estão rodando

Execute:

```bash
docker ps
```

O esperado é aparecerem containers semelhantes a:

```text
biblioteca_nginx
biblioteca_api
biblioteca_postgres
biblioteca_redis
```

O container `biblioteca_migrate` pode não aparecer no `docker ps`, pois ele executa as migrations e finaliza. Isso é normal.

Para verificar o resultado das migrations, use:

```bash
docker compose logs migrate
```

---

## Como acessar a aplicação

A API deve ser acessada através do Nginx pela porta 8080.

### Health check

```text
http://localhost:8080/health
```

### Documentação Swagger

```text
http://localhost:8080/api-docs
```

---

## Como realizar login e usar o token JWT

### 1. Acessar o Swagger

Abra no navegador:

```text
http://localhost:8080/api-docs
```

---

### 2. Fazer login

No Swagger, acesse a rota:

```text
POST /login
```

Clique em **Try it out** e envie o seguinte JSON:

```json
{
  "email": "admin@biblioteca.local",
  "password": "123456"
}
```

Depois clique em **Execute**.

Se o login estiver correto, a API retornará um token JWT parecido com este:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 3. Autorizar o token no Swagger

Copie somente o valor do token, sem aspas e sem o campo `"token"`.

No topo do Swagger, clique em:

```text
Authorize
```

Cole o token no campo de autorização.

Neste projeto, o Swagger já está configurado como Bearer Auth. Portanto, cole somente o token puro, sem escrever `Bearer` na frente.

Exemplo correto:

```text
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Depois clique em:

```text
Authorize
```

E depois em:

```text
Close
```

---

### 4. Testar uma rota protegida

Após autorizar o token, teste a rota:

```text
GET /books
```

Clique em **Try it out** e depois em **Execute**.

O esperado é retornar:

```text
Code 200
```

E uma lista de livros cadastrados.

---

## Rotas principais da API

A API possui rotas para as principais entidades do sistema:

### Autenticação

```text
POST /login
```

### Usuários

```text
GET /users
POST /users
GET /users/{id}
PUT /users/{id}
DELETE /users/{id}
```

### Categorias

```text
GET /categories
POST /categories
GET /categories/{id}
PUT /categories/{id}
DELETE /categories/{id}
```

### Livros

```text
GET /books
POST /books
GET /books/{id}
PUT /books/{id}
DELETE /books/{id}
```

### Autores

```text
GET /authors
POST /authors
GET /authors/{id}
PUT /authors/{id}
DELETE /authors/{id}
```

### Relação Livro-Autor

```text
GET /book-authors
POST /book-authors
GET /book-authors/{id}
PUT /book-authors/{id}
DELETE /book-authors/{id}
```

---

## Como executar as migrations pelo command

O projeto possui um command para executar as migrations do banco de dados.

### Executar migrations dentro do container da API

Com os containers rodando, execute:

```bash
docker compose exec api node src/command.js migrate
```

Esse comando executa as migrations responsáveis por criar ou atualizar a estrutura do banco de dados.

---

### Executar seed pelo command

Caso seja necessário inserir os dados iniciais novamente, execute:

```bash
docker compose exec api node src/command.js seed
```

O seed insere dados iniciais no banco, como usuários, categorias, autores, livros e relacionamentos entre livros e autores.

---

## Diferença entre migration e seed

### Migration

Migration é responsável por criar ou alterar a estrutura do banco de dados.

Exemplo:

```sql
CREATE TABLE users (...);
CREATE TABLE books (...);
CREATE TABLE authors (...);
```

### Seed

Seed é responsável por inserir dados iniciais no banco.

Exemplo:

```sql
INSERT INTO users (...);
INSERT INTO books (...);
INSERT INTO authors (...);
```

---

## Como parar os containers

Para parar os containers sem apagar os dados do banco, use:

```bash
docker compose down
```

Esse comando para e remove os containers, mas mantém os volumes.

---

## Como subir novamente depois de desligar o PC

Sempre que ligar o computador novamente, abra o Docker Desktop, vá até a pasta do projeto e execute:

```bash
docker compose up -d
```

Depois confira se os containers subiram:

```bash
docker ps
```

E acesse novamente:

```text
http://localhost:8080/api-docs
```

---

## Atenção sobre volumes

Não utilize o comando abaixo se quiser manter os dados do banco:

```bash
docker compose down -v
```

O parâmetro `-v` apaga os volumes do Docker. Como o PostgreSQL usa volume para persistir os dados, esse comando pode apagar os dados cadastrados.

---

## Teste de persistência

Para testar a persistência dos dados:

### 1. Criar um livro pelo Swagger

Acesse:

```text
POST /books
```

Exemplo de JSON:

```json
{
  "title": "Livro Persistencia",
  "isbn": "9788888888888",
  "publication_year": 2026,
  "category_id": 1
}
```

---

### 2. Buscar o livro criado

Acesse:

```text
GET /books
```

Ou:

```text
GET /books/{id}
```

Confirme que o livro foi criado.

---

### 3. Reiniciar os containers principais

Para reiniciar os containers sem apagar o banco e sem rodar novamente o seed, use:

```bash
docker compose restart postgres api nginx redis
```

Depois verifique:

```bash
docker ps
```

---

### 4. Buscar o livro novamente

Volte ao Swagger, faça login novamente, autorize o token JWT e pesquise o mesmo livro.

Se o livro continuar aparecendo, a persistência está funcionando corretamente.

---

## Comandos úteis

### Subir o projeto

```bash
docker compose up -d --build
```

### Ver containers rodando

```bash
docker ps
```

### Ver logs da API

```bash
docker compose logs api
```

### Ver logs das migrations

```bash
docker compose logs migrate
```

### Parar containers sem apagar volumes

```bash
docker compose down
```

### Reiniciar containers principais

```bash
docker compose restart postgres api nginx redis
```

### Executar migrations pelo command

```bash
docker compose exec api node src/command.js migrate
```

### Executar seed pelo command

```bash
docker compose exec api node src/command.js seed
```

---

## Usuário padrão para login

```text
Email: admin@biblioteca.local
Senha: 123456
```

---

## Resumo do funcionamento

O projeto funciona com uma arquitetura baseada em containers. O usuário acessa a aplicação pela porta 8080, onde o Nginx recebe a requisição e encaminha para a API Node.js. A API processa as regras de negócio, valida o token JWT nas rotas protegidas e acessa o banco PostgreSQL pela rede interna do Docker.

Fluxo da aplicação:

```text
Usuário → localhost:8080 → Nginx → API Node.js → PostgreSQL
```

O PostgreSQL utiliza volume Docker para manter os dados mesmo após reiniciar os containers.
