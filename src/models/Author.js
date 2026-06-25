const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Author = sequelize.define(
  "Author",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    nationality: { type: DataTypes.STRING(100), allowNull: true },
    birth_year: { type: DataTypes.INTEGER, allowNull: true },
  },
  { tableName: "authors", timestamps: true, underscored: true }
);

module.exports = Author;
