-- Agregações e relatórios — Biblioteca API

-- 1. Total de livros por categoria com percentual
SELECT
    c.name AS categoria,
    COUNT(b.id) AS total,
    ROUND(COUNT(b.id) * 100.0 / SUM(COUNT(b.id)) OVER (), 1) AS percentual
FROM categories c
LEFT JOIN books b ON b.category_id = c.id
GROUP BY c.id, c.name
ORDER BY total DESC;

-- 2. Autores com quantidade de livros (ranking)
SELECT
    a.id,
    a.name AS autor,
    a.nationality,
    COUNT(ba.book_id) AS total_livros
FROM authors a
LEFT JOIN book_authors ba ON ba.author_id = a.id
GROUP BY a.id, a.name, a.nationality
ORDER BY total_livros DESC;

-- 3. Livros publicados por década
SELECT
    (publication_year / 10) * 10 AS decada,
    COUNT(*) AS total
FROM books
WHERE publication_year IS NOT NULL
GROUP BY decada
ORDER BY decada;

-- 4. Autores com mais de 1 livro cadastrado
SELECT
    a.name,
    COUNT(ba.book_id) AS livros
FROM authors a
INNER JOIN book_authors ba ON ba.author_id = a.id
GROUP BY a.id, a.name
HAVING COUNT(ba.book_id) > 1
ORDER BY livros DESC;

-- 5. Categorias sem livros
SELECT c.name AS categoria_sem_livros
FROM categories c
LEFT JOIN books b ON b.category_id = c.id
WHERE b.id IS NULL;
