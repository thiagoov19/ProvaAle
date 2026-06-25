# Dicionário de Dados — Biblioteca API

Este documento descreve as tabelas, campos, restrições e relacionamentos do banco PostgreSQL utilizado pela Biblioteca API.

---

## Tabela: `users`

Armazena usuários que podem se autenticar no sistema.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INTEGER | PK, AUTO_INCREMENT | Identificador único do usuário |
| `name` | VARCHAR(100) | NOT NULL | Nome do usuário |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | Email utilizado no login |
| `password` | VARCHAR(255) | NOT NULL | Senha armazenada como hash bcrypt |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data de criação do registro |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data da última atualização |

---

## Tabela: `categories`

Armazena as categorias dos livros.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INTEGER | PK, AUTO_INCREMENT | Identificador único da categoria |
| `name` | VARCHAR(100) | UNIQUE, NOT NULL | Nome da categoria |
| `description` | TEXT | NULL | Descrição da categoria |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data de criação do registro |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data da última atualização |

---

## Tabela: `authors`

Armazena os autores cadastrados no sistema.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INTEGER | PK, AUTO_INCREMENT | Identificador único do autor |
| `name` | VARCHAR(100) | NOT NULL | Nome do autor |
| `nationality` | VARCHAR(100) | NULL | Nacionalidade do autor |
| `birth_year` | INTEGER | NULL | Ano de nascimento do autor |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data de criação do registro |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data da última atualização |

---

## Tabela: `books`

Armazena os livros cadastrados no acervo.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INTEGER | PK, AUTO_INCREMENT | Identificador único do livro |
| `title` | VARCHAR(255) | NOT NULL | Título do livro |
| `isbn` | VARCHAR(20) | UNIQUE, NULL | Código ISBN único do livro, quando informado |
| `publication_year` | INTEGER | NULL | Ano de publicação do livro |
| `category_id` | INTEGER | FK -> `categories.id`, NOT NULL | Categoria à qual o livro pertence |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data de criação do registro |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data da última atualização |

**Regra de integridade:** `category_id` referencia `categories.id`. O banco impede cadastrar livro com categoria inexistente.

---

## Tabela: `book_authors`

Tabela pivô que resolve o relacionamento N:N entre `books` e `authors`. Cada linha representa um vínculo entre um livro e um autor.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | INTEGER | PK, AUTO_INCREMENT | Identificador único do relacionamento |
| `book_id` | INTEGER | FK -> `books.id`, NOT NULL | Livro relacionado |
| `author_id` | INTEGER | FK -> `authors.id`, NOT NULL | Autor relacionado |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data de criação do vínculo |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Data da última atualização |

**Restrição composta:** `UNIQUE(book_id, author_id)`, que impede cadastrar duas vezes o mesmo autor no mesmo livro.

---

## Resumo dos relacionamentos

| Origem | Destino | Tipo | Implementação |
|---|---|---|---|
| `categories` | `books` | 1:N | `books.category_id` |
| `books` | `authors` | N:N | `book_authors.book_id` + `book_authors.author_id` |
| `users` | — | Sem relacionamento | Usada para autenticação |

---

## Índices principais

| Índice | Campo | Motivo |
|---|---|---|
| `idx_books_title` | `books.title` | Busca por título |
| `idx_books_category` | `books.category_id` | Filtro/JOIN por categoria |
| `idx_authors_name` | `authors.name` | Busca por nome de autor |
| `idx_book_authors_book` | `book_authors.book_id` | JOIN livro -> autor |
| `idx_book_authors_author` | `book_authors.author_id` | JOIN autor -> livro |
| `idx_book_authors_book_author_unique` | `book_authors.book_id`, `book_authors.author_id` | Impedir vínculo duplicado entre livro e autor |
