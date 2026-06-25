const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Book = sequelize.define(
  "Book",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    title: { type: DataTypes.STRING(255), allowNull: false },
    isbn: { type: DataTypes.STRING(20), allowNull: true, unique: true },
    publication_year: { type: DataTypes.INTEGER, allowNull: true },
    category_id: { type: DataTypes.INTEGER, allowNull: false },
  },
  { tableName: "books", timestamps: true, underscored: true }
);

module.exports = Book;
