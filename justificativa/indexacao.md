# Justificativa de Indexação — Biblioteca API

A estratégia de indexação foi definida com base nas consultas mais frequentes do sistema: busca de livros por título, filtros por categoria e JOINs entre livros e autores.

| Índice | Campo | Tipo | Motivo |
|---|---|---|---|
| `idx_books_title` | `books.title` | B-Tree | Acelerar buscas por título de livro |
| `idx_books_category` | `books.category_id` | B-Tree | Acelerar filtros e JOINs por categoria |
| `idx_authors_name` | `authors.name` | B-Tree | Acelerar busca por nome de autor |
| `idx_book_authors_book` | `book_authors.book_id` | B-Tree | Acelerar JOINs partindo de livros para autores |
| `idx_book_authors_author` | `book_authors.author_id` | B-Tree | Acelerar JOINs partindo de autores para livros |
| `idx_book_authors_book_author_unique` | `book_authors.book_id`, `book_authors.author_id` | B-Tree UNIQUE | Impedir vínculo duplicado entre o mesmo livro e autor |

## Exemplos de uso

Busca por título:

```sql
SELECT *
FROM books
WHERE title ILIKE '%Biblioteca%';
```

Livros por categoria:

```sql
SELECT b.title, c.name
FROM books b
JOIN categories c ON c.id = b.category_id
WHERE b.category_id = 1;
```

Livros com autores:

```sql
SELECT b.title, a.name
FROM books b
JOIN book_authors ba ON ba.book_id = b.id
JOIN authors a ON a.id = ba.author_id;
```

## Observação

O PostgreSQL usa índices B-Tree por padrão quando o tipo não é especificado. Esse tipo de índice é adequado para buscas, filtros e ordenações comuns em campos textuais e numéricos.
