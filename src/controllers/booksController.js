const { Book, Category, Author, BookAuthor } = require("../models");

module.exports = {
  async list(req, res) {
    try {
      const books = await Book.findAll({
        include: [
          { model: Category, as: "category" },
          { model: Author, as: "authors", through: { attributes: [] } },
        ],
      });
      res.json(books);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async get(req, res) {
    try {
      const b = await Book.findByPk(req.params.id, {
        include: [
          { model: Category, as: "category" },
          { model: Author, as: "authors", through: { attributes: [] } },
        ],
      });
      if (!b) return res.status(404).json({ error: "Livro não encontrado" });
      res.json(b);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async create(req, res) {
    try {
      const { title, isbn, publication_year, category_id } = req.body;
      if (!title || !category_id) return res.status(400).json({ error: "title e category_id são obrigatórios" });
      const cat = await Category.findByPk(category_id);
      if (!cat) return res.status(404).json({ error: "Categoria não encontrada" });
      const b = await Book.create({ title, isbn, publication_year, category_id });
      res.status(201).json(b);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async update(req, res) {
    try {
      const b = await Book.findByPk(req.params.id);
      if (!b) return res.status(404).json({ error: "Livro não encontrado" });
      if (req.body.category_id) {
        const cat = await Category.findByPk(req.body.category_id);
        if (!cat) return res.status(404).json({ error: "Categoria não encontrada" });
      }
      await b.update(req.body);
      res.json(b);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async remove(req, res) {
    try {
      const b = await Book.findByPk(req.params.id);
      if (!b) return res.status(404).json({ error: "Livro não encontrado" });
      await b.destroy();
      res.status(204).send();
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async listAuthors(req, res) {
    try {
      const b = await Book.findByPk(req.params.bookId, {
        include: [{ model: Author, as: "authors", through: { attributes: [] } }],
      });
      if (!b) return res.status(404).json({ error: "Livro não encontrado" });
      res.json(b.authors);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async addAuthor(req, res) {
    try {
      const b = await Book.findByPk(req.params.bookId);
      if (!b) return res.status(404).json({ error: "Livro não encontrado" });
      const a = await Author.findByPk(req.params.authorId);
      if (!a) return res.status(404).json({ error: "Autor não encontrado" });
      const [link, created] = await BookAuthor.findOrCreate({
        where: { book_id: b.id, author_id: a.id },
      });
      if (!created) return res.status(409).json({ error: "Autor já vinculado a este livro" });
      res.status(201).json(link);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async removeAuthor(req, res) {
    try {
      const deleted = await BookAuthor.destroy({
        where: { book_id: req.params.bookId, author_id: req.params.authorId },
      });
      if (!deleted) return res.status(404).json({ error: "Vínculo não encontrado" });
      res.status(204).send();
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
};
