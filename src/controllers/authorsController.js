const { Author } = require("../models");

module.exports = {
  async list(req, res) {
    try { res.json(await Author.findAll()); }
    catch (err) { res.status(500).json({ error: err.message }); }
  },
  async get(req, res) {
    try {
      const a = await Author.findByPk(req.params.id);
      if (!a) return res.status(404).json({ error: "Autor não encontrado" });
      res.json(a);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async create(req, res) {
    try {
      const { name, nationality, birth_year } = req.body;
      if (!name) return res.status(400).json({ error: "name é obrigatório" });
      const a = await Author.create({ name, nationality, birth_year });
      res.status(201).json(a);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async update(req, res) {
    try {
      const a = await Author.findByPk(req.params.id);
      if (!a) return res.status(404).json({ error: "Autor não encontrado" });
      await a.update(req.body);
      res.json(a);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async remove(req, res) {
    try {
      const a = await Author.findByPk(req.params.id);
      if (!a) return res.status(404).json({ error: "Autor não encontrado" });
      await a.destroy();
      res.status(204).send();
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
};
