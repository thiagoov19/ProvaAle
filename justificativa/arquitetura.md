# Justificativa de Arquitetura — Biblioteca API

---

## 1. Definição da arquitetura

### 1.1 Escolha tecnológica

**Tipo de banco escolhido:** SQL, banco relacional.

**Provedor:** PostgreSQL 17+.

**Justificativa técnica:** O domínio da aplicação — gerenciamento de biblioteca — possui dados estruturados e relacionamentos bem definidos: livros pertencem a categorias, livros podem ter vários autores e autores podem participar de vários livros. Por esse motivo, um banco relacional é adequado, pois permite modelar entidades, chaves primárias, chaves estrangeiras, constraints e relacionamentos N:N com integridade referencial.

O PostgreSQL foi escolhido porque oferece suporte sólido a SQL, constraints, índices B-Tree, transações e integração madura com o Sequelize por meio do driver `pg`.

Um banco NoSQL não foi escolhido porque o projeto não exige documentos flexíveis ou estrutura variável. As entidades possuem campos previsíveis e se beneficiam da normalização relacional.

---

## 2. Requisitos do sistema

**Objetivo:** fornecer uma API REST para gerenciamento de acervo bibliográfico, permitindo cadastrar usuários, categorias, autores, livros e os vínculos entre livros e autores.

**Principais entidades:**

- `users`
- `categories`
- `books`
- `authors`
- `book_authors`

**Volume estimado de dados na carga inicial:**

| Tabela | Quantidade aproximada |
|---|---:|
| `users` | 10 |
| `categories` | 10 |
| `authors` | 40 |
| `books` | 60 |
| `book_authors` | 120 relações |

Total aproximado: **240 registros**, acima do mínimo de 100 registros relevantes exigido para avaliação de consultas e performance.

**Quantidade estimada de usuários:** pequena equipe administrativa/bibliotecários, com dezenas de usuários simultâneos no máximo.

**Principais consultas realizadas:**

- Listagem de livros com suas categorias.
- Listagem de livros com seus autores.
- Busca de livro por título.
- Relatório de livros por categoria.
- Relatório de autores com quantidade de livros.

---

## 3. Visão geral da infraestrutura

```text
Host -> Nginx -> API Node.js -> PostgreSQL
                      |
                    Redis
```

A solução segue a Opção A: Docker / Orquestração Local.

Serviços principais:

- `nginx`: ponto único de entrada externo.
- `api`: aplicação Node.js/Express.
- `postgres`: banco de dados relacional.
- `redis`: serviço de cache/apoio e validação via healthcheck.
- `migrate`: serviço temporário para migrations e seed.

---

## 4. Justificativa do Nginx

O Nginx foi adotado como proxy reverso porque centraliza o acesso externo e encaminha as requisições para a API Node.js dentro da rede Docker.

Vantagens:

- expõe apenas uma porta pública (`8080`) para o host;
- evita acesso direto ao container da aplicação;
- permite adicionar recursos como HTTPS, compressão, logs e rate limiting no futuro;
- separa a camada de borda da camada de aplicação.

---

## 5. Isolamento da API

A API usa `expose: 3000`, não `ports`. Isso significa que a porta 3000 fica disponível somente para outros containers na rede Docker, não diretamente para o host.

Assim, o fluxo correto é:

```text
Usuário -> localhost:8080 -> Nginx -> api:3000
```

Esse comportamento ajuda a cumprir o requisito de segurança: o Node.js fica privado e o acesso externo ocorre somente pelo Nginx.

---

## 6. Dockerfile multi-stage build

O Dockerfile utiliza múltiplos estágios para separar o ambiente de instalação/preparação do ambiente final de execução.

Benefícios:

- imagem final mais enxuta;
- melhor uso de cache de camadas;
- dependências instaladas antes da cópia completa do código;
- menor superfície de ataque em comparação com imagens cheias de ferramentas desnecessárias.

---

## 7. Rede Docker customizada

O Compose define redes customizadas para separar responsabilidades:

- `frontend_network`: comunicação entre Nginx e API.
- `backend_network`: comunicação entre API, PostgreSQL, Redis e serviço de migrations.

Os containers se comunicam por nome de serviço, como `postgres`, `redis` e `api`. Isso usa DNS interno do Docker e evita IPs estáticos.

A rede `backend_network` é interna, reforçando o isolamento do banco e do Redis.

---

## 8. Persistência de dados

O PostgreSQL utiliza named volume:

```text
biblioteca_postgres_data
```

Esse volume é montado em `/var/lib/postgresql/data`. Como o volume existe fora do ciclo de vida do container, os dados persistem mesmo após recriar o container do banco.

Somente o comando abaixo remove os dados persistidos:

```bash
docker compose down -v --remove-orphans
```

---

## 9. Redis

O Redis foi provisionado como serviço de cache/apoio da infraestrutura e está disponível na rede interna pelo nome `redis`.

Nesta versão acadêmica, ele é validado pelo endpoint `/health`, comprovando que a API consegue se comunicar com o serviço. Ele também deixa a arquitetura preparada para evolução futura, como cache de listagens de livros ou categorias.

Essa explicação evita afirmar que já há cache aplicado nas regras de negócio caso a API ainda não esteja usando Redis diretamente nas rotas.

---

## 10. Autenticação e JWT

A autenticação é feita por JWT.

Fluxo:

1. O usuário envia email e senha para `POST /login`.
2. A API busca o usuário na tabela `users`.
3. A senha enviada é comparada com o hash bcrypt salvo no banco.
4. Se estiver correta, a API retorna um token JWT.
5. O token deve ser enviado no header `Authorization: Bearer <token>` nas rotas protegidas.

O middleware de autenticação valida o token antes de permitir acesso aos controllers.

Rotas públicas:

- `/`
- `/health`
- `/api-docs`
- `/login`

Rotas de negócio são protegidas por JWT.

---

## 11. Automação local

A automação local é feita com Docker Compose e scripts auxiliares.

Comando principal:

```bash
docker compose up --build
```

Scripts auxiliares disponíveis no projeto:

```bash
./scripts/up.sh
./scripts/down.sh
./scripts/clean.sh
```

No Windows:

```cmd
scripts\up.bat
scripts\down.bat
scripts\clean.bat
```

O serviço `migrate` executa as migrations e o seed, automatizando a preparação do banco.

---

## 12. Evidências esperadas

Para a defesa técnica, devem ser coletadas evidências como:

```bash
docker compose up --build
docker ps
docker compose logs api
docker network inspect biblioteca-api_backend_network
docker volume inspect biblioteca-api_biblioteca_postgres_data
```

Também devem ser evidenciados:

- Swagger funcionando em `http://localhost:8080/api-docs`.
- Login retornando JWT.
- Rota protegida funcionando com token.
- Banco persistindo após reinicialização.
- API inacessível diretamente pelo host.
- Acesso funcionando pelo Nginx.

---

## 13. Considerações sobre ECR/CI-CD

A entrega principal do grupo segue a Opção A, com Docker local. Por isso, o foco da automação está em `docker compose up --build` e nos scripts `.sh`/`.bat` que sobem e limpam a infraestrutura.

Um pipeline com Amazon ECR pode ser usado como evolução futura, mas não deve ser descrito como implementado se não houver evidências reais de push/deploy no repositório.

---

## Conclusão

A arquitetura atende ao cenário proposto porque separa as camadas de aplicação, banco, cache e proxy reverso; isola serviços internos; usa volume nomeado para persistência; utiliza autenticação JWT e permite execução automatizada via Docker Compose.
