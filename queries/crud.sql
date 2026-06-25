-- CRUD básico — Biblioteca API

-- USERS
INSERT INTO users (name, email, password) VALUES ('Teste', 'teste@email.com', 'hash');
SELECT * FROM users;
SELECT * FROM users WHERE id = 1;
UPDATE users SET name = 'Novo Nome' WHERE id = 1;
DELETE FROM users WHERE id = 1;

-- CATEGORIES
INSERT INTO categories (name, description) VALUES ('Ficção', 'Obras de ficção geral');
SELECT * FROM categories;
SELECT * FROM categories WHERE id = 1;
UPDATE categories SET description = 'Nova descrição' WHERE id = 1;
DELETE FROM categories WHERE id = 1;

-- AUTHORS
INSERT INTO authors (name, nationality, birth_year) VALUES ('Autor Teste', 'Brasileiro', 1980);
SELECT * FROM authors;
SELECT * FROM authors WHERE id = 1;
UPDATE authors SET nationality = 'Português' WHERE id = 1;
DELETE FROM authors WHERE id = 1;

-- BOOKS
INSERT INTO books (title, isbn, publication_year, category_id) VALUES ('Livro Teste', '0000000000001', 2024, 1);
SELECT * FROM books;
SELECT * FROM books WHERE id = 1;
UPDATE books SET title = 'Título Atualizado' WHERE id = 1;
DELETE FROM books WHERE id = 1;

-- BOOK_AUTHORS
INSERT INTO book_authors (book_id, author_id) VALUES (1, 1);
SELECT * FROM book_authors WHERE book_id = 1;
DELETE FROM book_authors WHERE book_id = 1 AND author_id = 1;
