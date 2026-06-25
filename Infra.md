# Comandos finais para rodar e validar o projeto

## 1. Subir o ambiente

No Windows CMD:

```cmd
copy .env.example .env
docker compose up -d --build
```

No Linux/WSL/Git Bash:

```bash
cp .env.example .env
docker compose up -d --build
```

Também é possível subir sem criar `.env`, pois o `docker-compose.yml` possui valores padrão.

## 2. Acessar a aplicação

```text
API via Nginx: http://localhost:8080
Swagger:       http://localhost:8080/api-docs
Healthcheck:   http://localhost:8080/health
```

## 3. Login inicial

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

Use o token retornado no header das rotas protegidas:

```http
Authorization: Bearer SEU_TOKEN_AQUI
```

## 4. Comandos para evidências

```bash
docker ps
docker compose ps
docker compose logs api
docker compose logs nginx
docker compose logs postgres
docker compose logs redis
docker network ls
docker network inspect biblioteca-api_backend_network
docker volume ls
docker volume inspect biblioteca-api_biblioteca_postgres_data
```

Se o nome da rede ou volume mudar por causa do nome da pasta, use `docker network ls` e `docker volume ls` para identificar o nome correto.

## 5. Testar que a API está privada

Este acesso deve funcionar:

```text
http://localhost:8080/health
```

Este acesso deve falhar, pois a API não expõe porta direta:

```text
http://localhost:3000/health
```

## 6. Parar e limpar

Parar sem apagar os dados:

```bash
docker compose down
```

Apagar containers, redes e volumes, incluindo dados do banco:

```bash
docker compose down -v --remove-orphans
```
