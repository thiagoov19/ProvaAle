const jwt = require("jsonwebtoken");

module.exports = function authMiddleware(req, res, next) {
  const header = req.headers["authorization"];
  if (!header) return res.status(401).json({ error: "Token não fornecido" });

  const [, token] = header.split(" ");
  if (!token) return res.status(401).json({ error: "Formato inválido. Use: Bearer <token>" });

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET || "segredo-didatico-biblioteca-api");
    req.user = payload;
    next();
  } catch {
    return res.status(401).json({ error: "Token inválido ou expirado" });
  }
};
