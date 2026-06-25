const router = require("express").Router();
const auth = require("../middlewares/auth");
const authCtrl = require("../controllers/authController");
const usersCtrl = require("../controllers/usersController");
const categoriesCtrl = require("../controllers/categoriesController");
const authorsCtrl = require("../controllers/authorsController");
const booksCtrl = require("../controllers/booksController");

// Public
router.post("/login", authCtrl.login);

// Protected — Users
router.get("/users", auth, usersCtrl.list);
router.get("/users/:id", auth, usersCtrl.get);
router.post("/users", auth, usersCtrl.create);
router.put("/users/:id", auth, usersCtrl.update);
router.delete("/users/:id", auth, usersCtrl.remove);

// Protected — Categories
router.get("/categories", auth, categoriesCtrl.list);
router.get("/categories/:id", auth, categoriesCtrl.get);
router.post("/categories", auth, categoriesCtrl.create);
router.put("/categories/:id", auth, categoriesCtrl.update);
router.delete("/categories/:id", auth, categoriesCtrl.remove);

// Protected — Authors
router.get("/authors", auth, authorsCtrl.list);
router.get("/authors/:id", auth, authorsCtrl.get);
router.post("/authors", auth, authorsCtrl.create);
router.put("/authors/:id", auth, authorsCtrl.update);
router.delete("/authors/:id", auth, authorsCtrl.remove);

// Protected — Books
router.get("/books", auth, booksCtrl.list);
router.get("/books/:id", auth, booksCtrl.get);
router.post("/books", auth, booksCtrl.create);
router.put("/books/:id", auth, booksCtrl.update);
router.delete("/books/:id", auth, booksCtrl.remove);

// Protected — Book <-> Author pivot
router.get("/books/:bookId/authors", auth, booksCtrl.listAuthors);
router.post("/books/:bookId/authors/:authorId", auth, booksCtrl.addAuthor);
router.delete("/books/:bookId/authors/:authorId", auth, booksCtrl.removeAuthor);

module.exports = router;
