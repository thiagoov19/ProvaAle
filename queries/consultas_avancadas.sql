-- Consultas avançadas — Biblioteca API
-- Demonstram JOINs, filtros, relação N:N e otimização de índices

-- 1. Listar todos os livros com sua categoria (JOIN 1:N)
-- Importância: consulta principal da API GET /books, usa idx_books_category
SELECT
    b.id,
    b.title,
    b.isbn,
    b.publication_year,
    c.name AS category
FROM books b
INNER JOIN categories c ON c.id = b.category_id
ORDER BY b.title;

-- 2. Listar livros com todos os seus autores (JOIN N:N via pivô)
-- Importância: enriquece o retorno dos livros, usa idx_book_authors_book
SELECT
    b.id,
    b.title,
    STRING_AGG(a.name, ', ' ORDER BY a.name) AS autores
FROM books b
LEFT JOIN book_authors ba ON ba.book_id = b.id
LEFT JOIN authors a ON a.id = ba.author_id
GROUP BY b.id, b.title
ORDER BY b.title;

-- 3. Buscar livros por título (filtro com LIKE — usa idx_books_title)
-- Importância: busca textual eficiente aproveitando índice B-Tree
SELECT b.id, b.title, c.name AS category
FROM books b
INNER JOIN categories c ON c.id = b.category_id
WHERE b.title ILIKE '%machado%'
ORDER BY b.title;

-- 4. Buscar todos os livros de um autor específico (filtro por author_id)
-- Importância: uso direto de idx_book_authors_author + JOIN complexo
SELECT
    a.name AS autor,
    b.title,
    b.publication_year,
    c.name AS categoria
FROM authors a
INNER JOIN book_authors ba ON ba.author_id = a.id
INNER JOIN books b ON b.id = ba.book_id
INNER JOIN categories c ON c.id = b.category_id
WHERE a.id = 1
ORDER BY b.publication_year;

-- 5. Listar categorias e quantidade de livros em cada uma
-- Importância: relatório de distribuição do acervo, usa idx_books_category
SELECT
    c.name AS categoria,
    COUNT(b.id) AS total_livros
FROM categories c
LEFT JOIN books b ON b.category_id = c.id
GROUP BY c.id, c.name
ORDER BY total_livros DESC;
