-- Índices — Biblioteca API

-- Índice para busca por título de livro
CREATE INDEX IF NOT EXISTS idx_books_title         ON books(title);

-- Índice para filtro e JOIN por categoria
CREATE INDEX IF NOT EXISTS idx_books_category      ON books(category_id);

-- Índice para busca por nome de autor
CREATE INDEX IF NOT EXISTS idx_authors_name        ON authors(name);

-- Índices da tabela pivô para JOINs N:N
CREATE INDEX IF NOT EXISTS idx_book_authors_book   ON book_authors(book_id);
CREATE INDEX IF NOT EXISTS idx_book_authors_author ON book_authors(author_id);

-- Restrição/índice único para evitar o mesmo vínculo livro/autor duplicado
CREATE UNIQUE INDEX IF NOT EXISTS idx_book_authors_book_author_unique
    ON book_authors(book_id, author_id);

