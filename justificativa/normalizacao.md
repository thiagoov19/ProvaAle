# Justificativa de Normalização — Biblioteca API

---

## O que é normalização

Normalização é o processo de organizar as tabelas de um banco de dados para reduzir redundância de dados e evitar anomalias de inserção, atualização e exclusão. É feita em etapas chamadas "formas normais", cada uma mais restritiva que a anterior.

---

## 1ª Forma Normal (1FN)

**Regra:** todos os campos devem conter valores atômicos (indivisíveis), e não pode haver grupos repetidos ou listas dentro de uma mesma coluna.

**Como o esquema atende:**

- Nenhuma tabela possui colunas com múltiplos valores. Por exemplo, `authors.name` guarda um único nome por linha — nunca uma lista como `"Autor A, Autor B"`.
- O caso mais importante é o relacionamento entre `books` e `authors`. Se um livro pode ter vários autores, a abordagem que violaria a 1FN seria guardar isso como uma lista dentro da própria tabela `books`, por exemplo um campo `authors = "Autor A, Autor B, Autor C"`. Isso é proibido pela 1FN, porque o campo deixaria de ser atômico.
- A solução adotada foi criar a tabela pivô `book_authors`, onde cada linha representa exatamente um par livro-autor. Assim cada célula de cada tabela guarda um único valor atômico.

✅ **O esquema está na 1FN.**

---

## 2ª Forma Normal (2FN)

**Regra:** a tabela precisa estar na 1FN, e todo campo não-chave precisa depender da chave primária **inteira**. Esse problema só existe em tabelas com chave primária composta (formada por mais de uma coluna).

**Como o esquema atende:**

- Todas as tabelas do projeto usam uma chave primária simples e substituta (`id`, autoincrementável), inclusive a tabela pivô `book_authors`. Como não existe chave primária composta em nenhuma tabela, não há como existir dependência parcial — a 2FN é satisfeita automaticamente.
- A chave candidata "natural" de `book_authors` seria o par `(book_id, author_id)`. Para evitar a complexidade de chaves compostas, optou-se por manter `id` como chave primária simples e garantir a unicidade do par com a restrição `UNIQUE(book_id, author_id)`.

✅ **O esquema está na 2FN.**

---

## 3ª Forma Normal (3FN)

**Regra:** a tabela precisa estar na 2FN, e nenhum campo não-chave pode depender de outro campo não-chave (dependência transitiva). Todo campo não-chave deve depender **somente** da chave primária.

**Como o esquema atende:**

- `books.category_id` armazena apenas a referência (chave estrangeira) para `categories` — o nome ou descrição da categoria não são duplicados dentro de `books`. Se fossem, uma atualização no nome da categoria exigiria atualizar todos os livros daquela categoria, gerando anomalia de atualização.
- `book_authors` armazena apenas as chaves estrangeiras `book_id` e `author_id`, sem duplicar dados de `books` ou `authors` dentro da pivô.
- Em `authors`, campos como `nationality` e `birth_year` descrevem diretamente o autor (dependem só do `id`), não dependem de nenhum outro campo não-chave.
- Em `users`, todos os campos (`name`, `email`, `password`) dependem exclusivamente do `id`, sem dependências cruzadas entre si.

✅ **O esquema está na 3FN.**

---

## Desnormalização

**Não há desnormalização intencional neste projeto.**

Todas as tabelas seguem rigorosamente a 3FN. Não foi necessário desnormalizar nenhuma tabela para otimização de performance, pois o volume de dados esperado (centenas de registros) não justifica esse trade-off. A separação entre entidades (`books`, `authors`, `categories`) com relacionamentos via chaves estrangeiras é suficiente para as consultas requeridas pelo sistema, e os índices criados pelo Thiago nas chaves estrangeiras e campos de busca frequente garantem performance adequada sem abrir mão da integridade referencial.

---

## Conclusão

O esquema do projeto está normalizado até a 3ª Forma Normal:
- **1FN:** valores atômicos em todas as colunas, sem listas. A tabela pivô `book_authors` resolve o N:N.
- **2FN:** satisfeita automaticamente por não existirem chaves primárias compostas.
- **3FN:** não há dependências transitivas — cada campo depende exclusivamente da sua chave primária.

Não há desnormalização. O esquema prioriza integridade de dados sobre micro-otimizações de leitura, adequado para o volume e os casos de uso do sistema.
