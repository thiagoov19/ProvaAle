const express = require("express");
const swaggerUi = require("swagger-ui-express");
const YAML = require("yamljs");
const path = require("path");
const routes = require("./routes");

const app = express();
app.use(express.json());

// Health check
app.get("/health", async (req, res) => {
  const sequelize = require("./config/database");
  let db = "ok", redis = "ok";
  try { await sequelize.authenticate(); } catch { db = "error"; }
  try {
    await new Promise((resolve, reject) => {
      const net = require("net");
      const socket = net.createConnection(
        parseInt(process.env.REDIS_PORT || "6379"),
        process.env.REDIS_HOST || "redis"
      );
      socket.setTimeout(2000);
      socket.on("connect", () => { socket.destroy(); resolve(); });
      socket.on("error", reject);
      socket.on("timeout", reject);
    });
  } catch { redis = "unavailable"; }
  res.json({ status: "ok", db, redis });
});

// Swagger
const swaggerDoc = YAML.load(path.join(__dirname, "swagger/swagger.yaml"));
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDoc));

// Root
app.get("/", (req, res) => res.json({ message: "Biblioteca API", docs: "/api-docs" }));

// Routes
app.use(routes);

module.exports = app;
