# Seed SQL

A carga inicial do banco é feita pelo arquivo `scripts/seed.sql`.

No Docker, o serviço `migrate` executa primeiro `src/database/migrate.js` para criar a estrutura do banco e depois executa `src/database/run-sql-seed.js`, que lê e roda o SQL deste arquivo.

O seed começa com `TRUNCATE ... RESTART IDENTITY CASCADE` para permitir que o projeto seja reiniciado do zero sem duplicar dados em campos `UNIQUE`, como `users.email`, `books.isbn` e `book_authors(book_id, author_id)`.

Usuário padrão de login:

```text
email: admin@biblioteca.local
senha: 123456
```
