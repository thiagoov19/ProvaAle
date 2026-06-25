const User = require("./User");
const Category = require("./Category");
const Author = require("./Author");
const Book = require("./Book");
const BookAuthor = require("./BookAuthor");

// Category 1:N Books
Category.hasMany(Book, { foreignKey: "category_id", as: "books" });
Book.belongsTo(Category, { foreignKey: "category_id", as: "category" });

// Books N:N Authors via BookAuthor
Book.belongsToMany(Author, { through: BookAuthor, foreignKey: "book_id", otherKey: "author_id", as: "authors" });
Author.belongsToMany(Book, { through: BookAuthor, foreignKey: "author_id", otherKey: "book_id", as: "books" });

BookAuthor.belongsTo(Book, { foreignKey: "book_id" });
BookAuthor.belongsTo(Author, { foreignKey: "author_id" });

module.exports = { User, Category, Author, Book, BookAuthor };
