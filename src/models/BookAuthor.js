const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const BookAuthor = sequelize.define(
  "BookAuthor",
  {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    book_id: { type: DataTypes.INTEGER, allowNull: false },
    author_id: { type: DataTypes.INTEGER, allowNull: false },
  },
  {
    tableName: "book_authors",
    timestamps: true,
    underscored: true,
    indexes: [{ unique: true, fields: ["book_id", "author_id"] }],
  }
);

module.exports = BookAuthor;
