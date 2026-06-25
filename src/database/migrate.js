const sequelize = require("../config/database");
const { QueryInterface, DataTypes } = require("sequelize");

async function migrate() {
  const qi = sequelize.getQueryInterface();

  console.log("Running migrations...");

  await qi.createTable("users", {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    email: { type: DataTypes.STRING(255), allowNull: false, unique: true },
    password: { type: DataTypes.STRING(255), allowNull: false },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  }).catch(() => console.log("Table users already exists"));

  await qi.createTable("categories", {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false, unique: true },
    description: { type: DataTypes.TEXT, allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  }).catch(() => console.log("Table categories already exists"));

  await qi.createTable("authors", {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    nationality: { type: DataTypes.STRING(100), allowNull: true },
    birth_year: { type: DataTypes.INTEGER, allowNull: true },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  }).catch(() => console.log("Table authors already exists"));

  await qi.createTable("books", {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    title: { type: DataTypes.STRING(255), allowNull: false },
    isbn: { type: DataTypes.STRING(20), allowNull: true, unique: true },
    publication_year: { type: DataTypes.INTEGER, allowNull: true },
    category_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: "categories", key: "id" },
      onDelete: "RESTRICT",
    },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  }).catch(() => console.log("Table books already exists"));

  await qi.createTable("book_authors", {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    book_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: "books", key: "id" },
      onDelete: "CASCADE",
    },
    author_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: "authors", key: "id" },
      onDelete: "CASCADE",
    },
    created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  }).catch(() => console.log("Table book_authors already exists"));

  // Índices
  const addIndex = (table, fields, name, options = {}) =>
    qi.addIndex(table, fields, { name, ...options }).catch(() => {});

  await addIndex("books", ["title"], "idx_books_title");
  await addIndex("books", ["category_id"], "idx_books_category");
  await addIndex("authors", ["name"], "idx_authors_name");
  await addIndex("book_authors", ["book_id"], "idx_book_authors_book");
  await addIndex("book_authors", ["author_id"], "idx_book_authors_author");

  // Restrição/índice único da tabela pivô para impedir vínculo duplicado
  await addIndex("book_authors", ["book_id", "author_id"], "idx_book_authors_book_author_unique", {
    unique: true,
  });

  console.log("Migrations completed.");
  await sequelize.close();
}

migrate().catch((err) => {
  console.error("Migration error:", err);
  process.exit(1);
});
