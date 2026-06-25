const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { User } = require("../models");

module.exports = {
  async login(req, res) {
    try {
      const { email, password } = req.body;
      if (!email || !password) return res.status(400).json({ error: "email e password são obrigatórios" });
      const user = await User.findOne({ where: { email } });
      if (!user) return res.status(401).json({ error: "Credenciais inválidas" });
      const valid = await bcrypt.compare(password, user.password);
      if (!valid) return res.status(401).json({ error: "Credenciais inválidas" });
      const token = jwt.sign(
        { id: user.id, email: user.email },
        process.env.JWT_SECRET || "segredo-didatico-biblioteca-api",
        { expiresIn: process.env.JWT_EXPIRES_IN || "24h" }
      );
      return res.json({ token });
    } catch (err) {
      return res.status(500).json({ error: "Erro interno", detail: err.message });
    }
  },
};
