const bcrypt = require("bcryptjs");
const { User } = require("../models");

module.exports = {
  async list(req, res) {
    try {
      const users = await User.findAll({ attributes: ["id", "name", "email", "created_at"] });
      res.json(users);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async get(req, res) {
    try {
      const user = await User.findByPk(req.params.id, { attributes: ["id", "name", "email", "created_at"] });
      if (!user) return res.status(404).json({ error: "Usuário não encontrado" });
      res.json(user);
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async create(req, res) {
    try {
      const { name, email, password } = req.body;
      if (!name || !email || !password) return res.status(400).json({ error: "name, email e password são obrigatórios" });
      const existing = await User.findOne({ where: { email } });
      if (existing) return res.status(409).json({ error: "Email já cadastrado" });
      const hash = await bcrypt.hash(password, 10);
      const user = await User.create({ name, email, password: hash });
      res.status(201).json({ id: user.id, name: user.name, email: user.email });
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async update(req, res) {
    try {
      const user = await User.findByPk(req.params.id);
      if (!user) return res.status(404).json({ error: "Usuário não encontrado" });
      const { name, email, password } = req.body;
      if (email && email !== user.email) {
        const existing = await User.findOne({ where: { email } });
        if (existing) return res.status(409).json({ error: "Email já cadastrado" });
      }
      const update = {};
      if (name) update.name = name;
      if (email) update.email = email;
      if (password) update.password = await bcrypt.hash(password, 10);
      await user.update(update);
      res.json({ id: user.id, name: user.name, email: user.email });
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
  async remove(req, res) {
    try {
      const user = await User.findByPk(req.params.id);
      if (!user) return res.status(404).json({ error: "Usuário não encontrado" });
      await user.destroy();
      res.status(204).send();
    } catch (err) { res.status(500).json({ error: err.message }); }
  },
};
