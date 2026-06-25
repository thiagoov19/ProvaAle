const { Sequelize } = require("sequelize");

const sequelize = new Sequelize(
  process.env.DB_NAME || "biblioteca",
  process.env.DB_USER || "biblioteca",
  process.env.DB_PASSWORD || "biblioteca",
  {
    host: process.env.DB_HOST || "postgres",
    port: parseInt(process.env.DB_PORT || "5432"),
    dialect: "postgres",
    logging: false,
  }
);

module.exports = sequelize;
