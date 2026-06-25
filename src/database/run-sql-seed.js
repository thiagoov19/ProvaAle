const fs = require("fs");
const path = require("path");
const sequelize = require("../config/database");

async function runSqlSeed() {
  try {
    // Verificar se o banco já possui dados (tabela users como indicador)
    const [results] = await sequelize.query("SELECT COUNT(*) AS count FROM users");
    const userCount = parseInt(results[0].count, 10);

    if (userCount > 0) {
      console.log(
        `Seed ignorado: banco já possui ${userCount} usuário(s). ` +
        "Para resetar, use 'docker compose down -v' e suba novamente."
      );
      await sequelize.close();
      process.exit(0);
      return;
    }

    // Banco vazio — executar seed normalmente
    const seedPath = path.resolve(__dirname, "../../scripts/seed.sql");
    const sql = fs.readFileSync(seedPath, "utf8");

    console.log("Banco vazio detectado. Executando seed inicial (scripts/seed.sql)...");
    await sequelize.query(sql);
    console.log("Seed SQL executado com sucesso.");

    await sequelize.close();
    process.exit(0);
  } catch (error) {
    // Se a tabela não existe ainda (ex: migrate não rodou), apenas avisar e sair com sucesso
    if (error.message && error.message.includes('relation "users" does not exist')) {
      console.log("Tabela users ainda não existe. Seed será executado na próxima inicialização.");
      await sequelize.close();
      process.exit(0);
      return;
    }
    console.error("Erro ao executar seed SQL:", error);
    process.exit(1);
  }
}

runSqlSeed();
