const { Category } = require("../models");

module.exports = {
  async list(req, res) {
    try { res.json(await Category.findAll()); }
    catch (err) { res.status(500).json({ error: err.message }); }
  },
  async get(req, res) {
    try {
      const c = await Category.findByPk(req.params.id);
      if (!c) return res.status(404).json({ error: "Categoria não encontrada" });
      res.json(c);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async create(req, res) {
    try {
      const { name, description } = req.body;
      if (!name) return res.status(400).json({ error: "name é obrigatório" });
      const existing = await Category.findOne({ where: { name } });
      if (existing) return res.status(409).json({ error: "Categoria já existe" });
      const c = await Category.create({ name, description });
      res.status(201).json(c);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async update(req, res) {
    try {
      const c = await Category.findByPk(req.params.id);
      if (!c) return res.status(404).json({ error: "Categoria não encontrada" });
      await c.update(req.body);
      res.json(c);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async remove(req, res) {
    try {
      const c = await Category.findByPk(req.params.id);
      if (!c) return res.status(404).json({ error: "Categoria não encontrada" });
      await c.destroy();
      res.status(204).send();
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
};
