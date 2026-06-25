const [,, command] = process.argv;

if (command === "migrate") {
  require("./src/database/migrate");
} else if (command === "seed") {
  require("./src/database/run-sql-seed");
} else {
  console.log("Uso: node command.js [migrate|seed]");
  process.exit(1);
}
