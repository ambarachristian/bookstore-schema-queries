# Tutor progress: Bookstore schema and queries

PostgreSQL · Level 1 of 5 (Foundations) · Project 3 of 26

## Tutor-mode rules (short version)
- One step per message, then wait for "done", "next", or pasted output.
- Each step: (a) what and why, (b) exact command or code with file path, (c) key ideas and new terms, (d) how to check it worked.
- The learner types everything. Claude only reads files, runs read-only checks, and writes this file.
- Code blocks under about 40 lines. Errors: explain the message, ask for the learner's guess, then fix.
- End of each milestone: 2–3 understanding questions, then a git commit (milestone 1 also creates a public GitHub repo and pushes).
- Start every message with the position, e.g. "Milestone 2 of 5 · Step 3".
- "resume" = read this file and the repo, summarize in three lines, continue with the next step.

## Stack
PostgreSQL 16 in Docker (Docker Compose), psql (run inside the container), one .sql file per milestone, git.
Windows 11, VS Code terminal is PowerShell.

## Milestone plan
1. Server, psql, database: `compose.yaml`, `sql/01_setup.sql`
2. Tables and constraints: `sql/02_schema.sql`
3. Load data and prove constraints reject bad rows: `sql/03_data.sql`, `data/*.csv`
4. Queries 1–10: `sql/04_queries_1_10.sql`
5. Queries 11–20 and README: `sql/05_queries_11_20.sql`, `README.md`

### Milestone 1 steps (expected)
1. Write `compose.yaml` describing the PostgreSQL 16 server. ✅
2. Start the server and check that it runs. ✅
3. Connect with psql and look around (`\conninfo`, `\l`, `\du`, `\q`). ✅
4. Create a role and the `bookstore` database in `sql/01_setup.sql` (run it with `\i`). ✅
5. Add a schema to the same file and run it again. ✅
6. Connect as `bookstore_app` and verify everything. ✅
7. Understanding check. ⏭️ skipped; ask before M2
8. Commit with git. ✅
9. Create a public GitHub repo and push. ✅

## Decisions so far
- psql runs inside the container (`docker compose exec`), so nothing extra to install on Windows.
- The project's `sql/` and `data/` folders are mounted into the container so psql can run our files and COPY can read CSVs. (PowerShell has no `<` input redirection, so piping files into psql is awkward.)
- A separate PostgreSQL 17 runs directly on Windows as service `postgresql-x64-17` and holds port 5432. The learner chose to leave it running.
- Host port is **5433** (`127.0.0.1:5433:5432`). The learner chose to keep it. The `learninghub-db-1` container that used 5433 was removed; its volume `learninghub_pgdata` still exists. If learninghub is started again, the two will clash on 5433. Switching to 5434 would fix it.
- Practice password `dev_only_password` lives in `compose.yaml` (public repo). OK only because the server is local-only. Explained to the learner.
- Files are saved with Windows line endings (CRLF). Fine for YAML and SQL. Keep in mind for CSVs and the git setup.

## Log
- 2026-10-28, session 1. The project folder was empty.
  - Setup · Step 0 done. Docker 29.3.1, Docker Compose v5.1.1, git 2.45.1.windows.1.
  - Read-only checks: Docker Desktop was not running. Port 5432 was in use by the Windows service `postgresql-x64-17`. Gave optional commands to stop it; the learner chose to leave it.
  - M1 · Step 1 done. `compose.yaml` correct (no tabs), `sql/` and `data/` exist, `docker compose config` OK. Docker Desktop now running.
  - Found port 5433 taken by `learninghub-db-1`. M1 · Step 2 given: change line 10 to `"127.0.0.1:5434:5432"`, run `docker compose up -d`, check `docker compose ps` and `docker compose logs db`. Showed `docker ps` as the way to spot port clashes.

  - Learner ran `docker compose up -d` without changing line 10. Server runs fine (PostgreSQL 16.15, init complete, ready to accept connections) but on 127.0.0.1:5433. Meanwhile the `learninghub-db-1` container was removed (volume `learninghub_pgdata` still exists). Asked whether they removed it; recommended switching to 5434 anyway and re-running `docker compose up -d` (recreates the container, keeps the volume).

  - Learner kept 5433. M1 · Step 2 done.
  - M1 · Step 3 given: `docker compose exec db psql -U postgres`, then `\conninfo`, `\l`, `\du`, `\q`. Explained server vs client, the psql prompt, meta-commands, databases (postgres, template0, template1), roles and superuser, and why no password is asked.

  - M1 · Step 3 done (learner said "done" without pasting; server still up).
  - M1 · Step 4 given: `sql/01_setup.sql` part 1. DROP DATABASE/ROLE IF EXISTS (makes the file re-runnable; also wipes data, warned), CREATE ROLE bookstore_app LOGIN PASSWORD 'bookstore_dev_pw', CREATE DATABASE bookstore OWNER bookstore_app. Run with `\i /sql/01_setup.sql`, check `\l` and `\du`.

  - M1 · Step 4 done. File correct. Verified: `bookstore` owned by `bookstore_app`; role has LOGIN + password, not superuser/createdb/createrole.
  - M1 · Step 5 given: add `\connect postgres postgres` after the header (can't drop the db you're in; bookstore_app can't drop roles), and at the end `\connect bookstore bookstore_app`, `CREATE SCHEMA shop;`, `ALTER DATABASE bookstore SET search_path = shop, public;`. Check: re-run `\i`, `\dn`, `SHOW search_path` before and after `\c bookstore` (setting applies to new connections only).

  - M1 · Step 5 done. Verified: `shop` owned by bookstore_app; bookstore has `search_path=shop, public`. Cosmetic only: the blank line after the header ended up after `\connect postgres postgres` (lines 9–10). Mentioned as optional.
  - M1 · Step 6 given: `docker compose exec db psql -U bookstore_app -d bookstore`, `\conninfo`, `CREATE DATABASE test_db;` (expect permission denied), `CREATE TABLE test_table (id integer);`, `\dt` (expect schema shop), `DROP TABLE test_table;`, `\q`.

  - M1 · Step 6 done. Verified: `shop` has 0 tables, no `test_db`, server log shows "permission denied to create database".
  - M1 · Step 7 given: three questions. (1) server vs database vs schema, where `shop` sits. (2) why `bookstore_app` and not `postgres`; what the test_db error proved. (3) why the first `SHOW search_path` still showed `"$user", public`.

  - Learner said "continue" without answering the M1 questions. **Ask the same three questions as a warm-up before M2 · Step 1.**
  - Git config (read-only check): user.name "AMBARA Christian Evrard", email ambara.evrard@hotmail.com, core.autocrlf true, init.defaultBranch main. `gh` 2.96.0 installed, logged in as `ambarachristian` (https, repo scope).
  - M1 · Step 8 given: `.gitignore` (.vscode/, Thumbs.db, desktop.ini, .env), `git init`, `git status`, `git add .`, `git status`, `git commit -m "Milestone 1: PostgreSQL 16 in Docker with bookstore role, database and schema"`, `git log --oneline`.

  - M1 · Step 8 done. Commit `5b9b7ec` "Milestone 1: ..." with .gitignore, TUTOR_PROGRESS.md, compose.yaml, sql/01_setup.sql. Repo name free on GitHub.
  - Note: TUTOR_PROGRESS.md is tracked, so Claude's updates show as "modified". The learner commits it with each milestone.
  - M1 · Step 9 given: `gh repo create bookstore-schema-queries --public --source=. --remote=origin --push --description "..."`, check `git remote -v`, `git status`, `gh repo view --web`.

  - M1 · Step 9 done. Repo public: https://github.com/ambarachristian/bookstore-schema-queries (origin, main tracks origin/main, commit 5b9b7ec pushed).
  - **Milestone 1 complete.**
  - M2 warm-up given: the three M1 questions again, shortened.

### Milestone 2 steps (expected), file `sql/02_schema.sql`
1. Normalization: plan the five tables and how they connect (design as a comment block at the top of the file). ✅
2. `authors` (primary key, identity, NOT NULL). ✅
3. `books` (foreign key to authors, CHECK price > 0, UNIQUE isbn). ✅
4. `customers` (UNIQUE email, NOT NULL). ✅
5. `orders` (foreign key to customers, default order date, CHECK on status). ✅
6. `order_items` (foreign keys to orders and books, CHECK quantity > 0, unit price). ✅
7. Rebuild from zero (01 then 02) from PowerShell and inspect. ✅
8. Understanding check. ⏭️ skipped
9. Commit and push. ✅

  - Learner skipped the warm-up again ("step 1"). Accepted. Keep asking at milestone ends (their rule), but don't block on it.
  - M2 · Step 1 given: create `sql/02_schema.sql` with header, `\connect bookstore bookstore_app`, and a DESIGN comment block (columns per table, relationships, choices: one author per book; order_items.unit_price = price paid). Explained normalization (anomalies, 1NF/2NF/3NF), PK, surrogate keys, FK, one-to-many, many-to-many/junction table, composite key.

### Column plan (agreed in the design comment)
- authors: author_id PK, first_name, last_name, country
- books: book_id PK, title, isbn, genre, price, published_year, stock, author_id FK
- customers: customer_id PK, first_name, last_name, email, city, joined_on
- orders: order_id PK, order_date, shipped_date, status, customer_id FK
- order_items: order_id FK, book_id FK, quantity, unit_price, PK (order_id, book_id)

  - M2 · Step 1 done. `sql/02_schema.sql` lines 1–32 correct (header, `\connect`, design comment).
  - M2 · Step 2 given: append DROP TABLE IF EXISTS for all five (order_items, orders, customers, books, authors) + `CREATE TABLE authors` (author_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, first_name text NOT NULL, last_name text NOT NULL, country text). Explained CREATE TABLE syntax, integer/text, identity (vs serial), PRIMARY KEY + index, NOT NULL and NULL, naming `author_id`.
  - Note for M3: identity is GENERATED ALWAYS, so sample data must not supply IDs in INSERT; rely on 1..N order after a fresh rebuild (01 → 02 → 03). COPY with an explicit column list that leaves out the ID.

  - M2 · Step 2 done. Lines 33–48 correct; `shop.authors` verified.
  - M2 · Step 3 given: `CREATE TABLE books` (book_id identity PK, title NOT NULL, isbn NOT NULL UNIQUE CHECK (isbn ~ '^[0-9]{13}$'), genre, price numeric(8,2) NOT NULL CHECK (price > 0), published_year CHECK BETWEEN 1450 AND 2100, stock NOT NULL DEFAULT 0 CHECK (stock >= 0), author_id NOT NULL REFERENCES authors (author_id)). Explained numeric vs float, CHECK (NULL passes), pattern match, UNIQUE, DEFAULT, REFERENCES (both directions), auto constraint names.

  - M2 · Step 3 done. `books` verified: 4 checks, books_isbn_key, books_author_id_fkey.
  - M2 · Step 4 given: `CREATE TABLE customers` (customer_id identity PK, first_name/last_name NOT NULL, email text NOT NULL UNIQUE CHECK (email LIKE '%_@_%._%'), city text, joined_on date NOT NULL DEFAULT current_date). Explained LIKE (% and _), why email is UNIQUE but not the PK, exact-match limit of UNIQUE, date type and ISO format, current_date (server is UTC).

  - M2 · Step 4 done. `customers` verified.
  - M2 · Step 5 given: `CREATE TABLE orders` (order_id identity PK, customer_id NOT NULL REFERENCES customers, order_date date NOT NULL DEFAULT current_date, shipped_date date, status text NOT NULL DEFAULT 'pending' CHECK (status IN (...4 values)), table-level `CONSTRAINT shipped_after_ordered CHECK (shipped_date >= order_date)`). Explained IN (vs a lookup table), single vs double quotes, table-level vs column-level, naming a constraint, NULL passes again, why no `total` column.

  - M2 · Step 5 done. `orders` verified.
  - M2 · Step 6 given: `CREATE TABLE order_items` (order_id integer REFERENCES orders ON DELETE CASCADE, book_id integer REFERENCES books, quantity integer NOT NULL CHECK (quantity > 0), unit_price numeric(8,2) NOT NULL CHECK (unit_price > 0), PRIMARY KEY (order_id, book_id)). Explained composite PK as a table constraint (implies NOT NULL), ON DELETE CASCADE for order_id vs the default (refuse) for book_id, unit_price > 0 rules out free books.

  - M2 · Step 6 done. `order_items` verified; 5 tables in shop.
  - M2 · Step 7 given: rebuild from zero from PowerShell. Close psql first (DROP DATABASE fails if a session is connected). `docker compose exec db psql -U postgres -v ON_ERROR_STOP=1 -f /sql/01_setup.sql`, then `docker compose exec db psql -U bookstore_app -d bookstore -v ON_ERROR_STOP=1 -f /sql/02_schema.sql`, then `... -c "\dt"`. Explained -f, -c, ON_ERROR_STOP, file order.

  - M2 · Step 7 done. Rebuild OK: 5 empty tables, 20 constraints in shop (1+7+3+4+5), no server errors.
  - M2 · Step 8 given: three questions. (1) why order_items exists + two-column key. (2) book with no published_year: accepted or refused, why. (3) CASCADE on order_id but refuse on book_id: why.

  - Learner skipped the M2 questions ("continue").
  - M2 · Step 9 given: `git status`, `git add sql/02_schema.sql TUTOR_PROGRESS.md`, `git commit -m "Milestone 2: bookstore tables with keys and constraints"`, `git push`, `git log --oneline`.

### Milestone 3 plan (draft), file `sql/03_data.sql` + `data/*.csv`
- Permissions: server-side `COPY ... FROM '/data/x.csv'` needs superuser or `pg_read_server_files`; bookstore_app has neither. Use psql's `\copy` (client-side, runs as bookstore_app, reads /data inside the container). Explain the difference. `\copy` must be on one line.
- Don't supply identity IDs. Load in order authors → books → customers → orders → order_items; IDs become 1..N on a fresh rebuild. Start 03 with TRUNCATE ... RESTART IDENTITY CASCADE so it can be re-run.
- Data shape for the 20 queries: ~8 authors (one with no books), ~20 books across several genres (some never sold, one with stock 0, one with NULL published_year), ~12 customers in a few cities (some with no orders), ~25 orders over 2025–2026 with all four statuses (pending ones with NULL shipped_date), ~50 order_items.
- Steps: 1 INSERT authors; 2 books.csv + `\copy`; 3 INSERT customers; 4 orders + order_items; 5 rebuild 01→02→03 and count rows; 6–7 bad-row tests (negative price, bad ISBN, duplicate email, unknown author_id, shipped before ordered, bad status, quantity 0), each must fail with its constraint name. Probably a separate file `sql/03_bad_data_tests.sql` run without ON_ERROR_STOP; 8 understanding check; 9 commit + push.

  - M2 · Step 9 done. Commit `f5377f7` pushed; origin/main matches.
  - **Milestone 2 complete.**
  - M3 · Step 1 given: create `sql/03_data.sql` with header, `\connect bookstore bookstore_app`, `TRUNCATE order_items, orders, customers, books, authors RESTART IDENTITY;`, and a 9-row INSERT into authors. Check: `\i`, `SELECT * FROM authors;`, optional `\pset null '(null)'`.

### Sample data (keep consistent across steps)
Authors (IDs after a fresh load):
1 Chinua Achebe, Nigeria · 2 Jane Austen, United Kingdom · 3 Gabriel García Márquez, Colombia · 4 Chimamanda Ngozi Adichie, Nigeria · 5 George Orwell, United Kingdom · 6 Haruki Murakami, Japan · 7 Mongo Beti, Cameroon · 8 Toni Morrison, United States (**no books**) · 9 Amina Diallo, NULL country (fictional)

Books (book_id after load · author · genre · price · year · stock):
1 Things Fall Apart (1, Classic, 12.99, 1958, 14) · 2 No Longer at Ease (1, Literary Fiction, 11.50, 1960, 6) · 3 Arrow of God (1, Literary Fiction, 13.25, 1964, 3) · 4 Pride and Prejudice (2, Classic, 8.99, 1813, 20) · 5 Sense and Sensibility (2, Classic, 8.49, 1811, 9) · 6 Emma (2, Classic, 9.25, 1815, **0**) · 7 One Hundred Years of Solitude (3, Magical Realism, 16.80, 1967, 11) · 8 Love in the Time of Cholera (3, Magical Realism, 15.40, 1985, 5) · 9 Chronicle of a Death Foretold (3, Literary Fiction, 10.90, 1981, 2) · 10 Half of a Yellow Sun (4, Literary Fiction, 14.99, 2006, 8) · 11 Americanah (4, Literary Fiction, 15.99, 2013, 12) · 12 "Dear Ijeawele, or A Feminist Manifesto in Fifteen Suggestions" (4, Essay, 7.99, 2017, 15; comma → quoted in CSV) · 13 Nineteen Eighty-Four (5, Dystopian, 10.99, 1949, 25) · 14 Animal Farm (5, Dystopian, 7.50, 1945, 18) · 15 Homage to Catalonia (5, Essay, 12.00, 1938, 1) · 16 Norwegian Wood (6, Literary Fiction, 13.99, 1987, 7) · 17 Kafka on the Shore (6, Magical Realism, 17.50, 2002, 4) · 18 1Q84 (6, Magical Realism, 24.50, 2009, 2) · 19 Mission to Kala (7, Classic, 11.75, 1957, 6) · 20 The Poor Christ of Bomba (7, Classic, 12.40, 1956, 3) · 21 Harmattan Letters (9, Literary Fiction, 18.00, **NULL year**, 10; fictional)
- Plan: leave some books never sold (e.g. 3 Arrow of God, 15 Homage to Catalonia, 21 Harmattan Letters).

  - M3 · Step 1 done. 9 authors verified, UTF-8 OK.
  - M3 · Step 2 given: `data/books.csv` (header + 21 rows above) and one `\copy books (title, isbn, genre, price, published_year, stock, author_id) FROM '/data/books.csv' WITH (FORMAT csv, HEADER true)` line after the authors INSERT. Explained CSV, quoting, COPY vs \copy (pg_read_server_files), HEADER, empty = NULL, one-line rule, constraints still apply.

Customers (customer_id · city · joined_on), emails firstname.lastname@example.com:
1 Aïcha Bello, Douala, 2025-01-14 · 2 Jean-Paul Mbarga (jeanpaul.mbarga@), Yaoundé, 2025-02-03 · 3 Chidi Okafor, Lagos, 2025-03-22 · 4 Claire Dubois, Paris, 2025-04-10 · 5 Liam O'Brien (liam.obrien@), London, 2025-05-18 · 6 Fatima Njoya, Douala, 2025-07-01 · 7 Emeka Eze, Lagos, 2025-09-09 · 8 Sophie Martin, Paris, 2025-11-25 · 9 Samuel Etoga, Yaoundé, 2026-01-12 · 10 Grace Adeyemi, Lagos, 2026-04-30 · 11 Thomas Wright, London, 2026-08-15 (**no orders**) · 12 Brigitte Ateba, NULL city, 2026-10-02 (**no orders**)
- M5 note: queries relative to current_date drift over time. Consider a fixed reference date in M5 queries, or accept drift and say so in the README.

  - M3 · Step 2 done. 21 books verified (CRLF CSV loaded fine).
  - M3 · Step 3 given: 12-row INSERT into customers (list above). Explained '' for apostrophes, ISO date literals, example.com.

Orders (order_id · customer · order_date · shipped_date · status):
1 c1 2025-02-10 2025-02-12 delivered · 2 c2 2025-03-05 2025-03-08 delivered · 3 c1 2025-04-18 2025-04-21 delivered · 4 c3 2025-05-02 2025-05-06 delivered · 5 c4 2025-06-14 2025-06-16 delivered · 6 c2 2025-07-20 NULL cancelled · 7 c5 2025-08-03 2025-08-05 delivered · 8 c3 2025-09-15 2025-09-19 delivered · 9 c6 2025-10-01 2025-10-03 delivered · 10 c1 2025-11-11 2025-11-14 delivered · 11 c7 2025-12-02 2025-12-09 delivered (7 days) · 12 c4 2025-12-20 2025-12-22 delivered · 13 c8 2026-01-08 2026-01-10 delivered · 14 c3 2026-02-14 2026-02-17 delivered · 15 c9 2026-03-03 2026-03-05 delivered · 16 c6 2026-04-22 NULL cancelled · 17 c1 2026-05-30 2026-06-02 delivered · 18 c10 2026-06-18 2026-06-20 delivered · 19 c5 2026-07-25 2026-07-28 delivered · 20 c3 2026-08-30 2026-09-02 delivered · 21 c7 2026-09-21 2026-09-24 delivered · 22 c9 2026-10-12 2026-10-15 shipped · 23 c1 2026-10-20 2026-10-22 shipped · 24 c10 2026-10-25 NULL pending · 25 c2 2026-10-27 NULL pending
- Orders per customer: c1 5, c2 3, c3 4, c4–c7 2 each, c8 1, c9 2, c10 2.

### Milestone 3 steps (revised)
1. Authors INSERT ✅ · 2. books.csv + \copy ✅ · 3. Customers INSERT ✅ · 4. Orders INSERT · 5. order_items.csv + \copy · 6. Rebuild 01→02→03, count rows · 7–8. Bad-row tests · 9. Understanding check · 10. Commit + push

  - M3 · Step 3 done. 12 customers verified.
  - M3 · Step 4 given: 25-row INSERT into orders (list above). Explained numbers vs quoted values, the FK check, exact lowercase status, NULL shipped_date, row-only rules (an order before the customer joined isn't caught).

Order items (order: book×qty@price), 38 rows, total quantity 48:
o1: 1×1@11.99*, 13×1@10.99 · o2: 7×1@16.80, 4×2@8.99 · o3: 11×1@15.99 · o4: 1×2@11.99*, 10×1@14.99 · o5: 4×1@8.99, 5×1@8.49 · o6 (cancelled): 18×1@22.00* · o7: 13×2@10.99, 14×1@7.50 · o8: 7×1@16.80, 8×1@15.40 · o9: 19×1@11.75, 20×1@12.40 · o10: 16×1@13.99 · o11: 2×1@11.50, 12×3@7.99 · o12: 13×1@10.99 · o13: 11×1@15.99 · o14: 18×1@24.50, 17×1@17.50 · o15: 19×2@11.75, 1×1@12.99 · o16 (cancelled): 7×1@16.80 · o17: 12×1@7.99, 11×1@15.99 · o18: 4×1@8.99 · o19: 9×1@10.90 · o20: 13×3@10.99, 14×2@7.50 · o21: 20×1@12.40, 1×1@12.99 · o22: 11×2@15.99 · o23: 8×1@15.40 · o24 (pending): 6×1@9.25 (Emma, stock 0) · o25 (pending): 10×1@14.99
- `*` = older price, below today's books.price (3 lines).
- Never sold: books 3, 15, 21. Authors with no sales: 8 Morrison (no books), 9 Diallo.

  - M3 · Step 4 done. 25 orders verified (19/2/2/2).
  - M3 · Step 5 given: `data/order_items.csv` (header + 38 rows above), `\copy order_items (order_id, book_id, quantity, unit_price) FROM '/data/order_items.csv' WITH (FORMAT csv, HEADER true)`. Check: `COPY 38`, `SELECT * FROM order_items WHERE order_id = 11;`.

  - M3 · Step 5 done. 38 lines, qty 48, 3 older-price lines, unsold books 3/15/21 verified.
  - M3 · Step 6 given: add a row-count query (count(*) + UNION ALL, 5 tables) at the end of 03_data.sql, then full rebuild from PowerShell: 01 (postgres), 02, 03 (bookstore_app), all with `-v ON_ERROR_STOP=1`. Close psql first.

  - M3 · Step 6 done. Counts 9/21/12/25/38 verified, no server errors.
  - M3 · Step 7 given: new file `sql/03_bad_data_tests.sql` (a second file for M3: a deliberate exception to "one .sql per milestone", told to the learner, who can object). Tests 1–7 on books: negative price, price 0, ISBN with dash, duplicate ISBN, author 99, missing title, UPDATE stock -1. Uses `\echo` labels. Explained reading ERROR/DETAIL, sequence gaps (book_id 22, 23, ... used up by failed inserts), UPDATE.

  - M3 · Step 7 done. 7 errors in the server log with the expected rule names; books 21, book 1 stock 14.
  - M3 · Step 8 given: tests 8–16 appended. 8 duplicate email, 9 bad email, 10 status 'lost', 11 shipped before ordered, 12 customer 99, 13 quantity 0 (order 1, book 4), 14 duplicate (1,1), 15 DELETE book 13 (sold), 16 DELETE author 1 (has books). Then a UNION ALL count check (must stay 9/21/12/25/38).

  - M3 · Step 8 done. All 16 tests refused with the expected rules (log tally checked); counts 9/21/12/25/38.
  - **"Finished when", part 1 met: the schema rejects bad data (16 tests).** Part 2 (20 correct queries) is still to do.
  - M3 · Step 9 given: three questions (RESTART IDENTITY; COPY vs \copy; why "Failing row contains (22, ...)").

  - Learner skipped the M3 questions ("done").
  - M3 · Step 10 given: `git add sql/03_data.sql sql/03_bad_data_tests.sql data/books.csv data/order_items.csv TUTOR_PROGRESS.md`, commit "Milestone 3: sample data via INSERT and COPY, plus constraint tests", push.

### Milestone 4 plan (draft), file `sql/04_queries_1_10.sql`, one query per step
- Q1 SELECT + ORDER BY: all books with price, most expensive first.
- Q2 WHERE (AND/comparison): books with fewer than 5 copies in stock (reorder list).
- Q3 WHERE with IN / IS NULL / LIKE: e.g. customers in Lagos or Douala; books with no known year.
- Q4 INNER JOIN: each book with its author's full name (string concatenation `||`).
- Q5 multi-table JOIN: lines of one order with customer, title and line total (quantity * unit_price).
- Q6 LEFT JOIN: every author with their books, including authors with none (Morrison); explain RIGHT and FULL JOIN here.
- Q7 GROUP BY + count: number of titles per genre.
- Q8 GROUP BY + SUM + JOIN + WHERE: revenue per genre, excluding cancelled orders.
- Q9 HAVING: customers who spent more than a threshold (excluding cancelled).
- Q10 ORDER BY + LIMIT with aggregate: top 5 books by copies sold.
- Then: run the whole file, understanding check, commit + push.
- Verify each query's result read-only against the sample data before telling the learner what to expect.

  - M3 · Step 10 done. Commit `82dc305` pushed (3 commits total), origin/main matches.
  - **Milestone 3 complete.**
  - M4 · Step 1 given: create `sql/04_queries_1_10.sql` with header, `\connect`, and Q1 (`\echo` label + `SELECT title, genre, price FROM books ORDER BY price DESC, title;`). Expected: 21 rows, 1Q84 24.50 first, Animal Farm 7.50 last. Explained SELECT/FROM/ORDER BY, DESC/ASC, tie-breaker, clause order, why no ORDER BY = no guaranteed order.

  - M4 · Step 1 done. Q1 correct (lines 1–10).
  - Tool note: in Git Bash, `psql -f /sql/...` gets path-mangled (MSYS). Use `MSYS_NO_PATHCONV=1` or run SELECTs with `-c`.
  - M4 · Step 2 given: Q2 `SELECT title, stock, price FROM books WHERE stock < 5 ORDER BY stock, title;`. Expected 7 rows: Emma 0, Homage to Catalonia 1, 1Q84 2, Chronicle of a Death Foretold 2, Arrow of God 3, The Poor Christ of Bomba 3, Kafka on the Shore 4.

  - At M4 · Step 2 the learner asked for "the complete two queries files". Reminded them of tutor mode and offered: faster steps / one per step / full files. **Learner chose: show both full files** (tutor mode off for the queries). Learner still pastes the files; Claude does not write project files.
  - Both files drafted in the scratchpad, all 20 run read-only against the data with ON_ERROR_STOP: no errors, results match hand calculations (genre revenue total = customer spend total = 535.57). Shown in chat in full.
  - Conventions: "sold" = status shipped or delivered. 05 uses `\set as_of '2026-10-28'` and `:'as_of'::date` (psql only) so date answers don't drift.

### Expected results (verified 2026-10-28)
Q1 21 rows, 1Q84 24.50 → Animal Farm 7.50 · Q2 7 rows (Emma 0 first) · Q3 4: Aïcha, Chidi, Fatima, Emeka · Q4 21 rows · Q5 8 lines (orders 4, 8, 14, 20) · Q6 Toni Morrison · Q7 5 genres (Literary Fiction 7) · Q8 Classic 166.45, Literary Fiction 131.33, Magical Realism 106.40, Dystopian 99.43, Essay 31.96 · Q9 Chidi 161.14, Aïcha 92.34, Samuel 68.47, Emeka 60.86 · Q10 1984 7, Americanah 5, Things Fall Apart 5, Dear Ijeawele 4, Pride and Prejudice 4 · Q11 9 books > 13.10 · Q12 Arrow of God, Harmattan Letters, Homage to Catalonia · Q13 Aïcha, Chidi, Emeka, Samuel, Sophie · Q14 Thomas Wright, Brigitte Ateba · Q15 Aïcha, Grace, Jean-Paul, Samuel · Q16 1/6/14 · Q17 1 gold, 4 silver, 5 bronze, 2 new · Q18 2025: 11, 3.1, 7; 2026: 10, 2.6, 3 · Q19 orders 22 (16 d), 23 (8), 24 (3), 25 (1) · Q20 9 months, no April

  - Learner pasted both files. Verified: identical to the tested drafts (ignoring CRLF), both run with ON_ERROR_STOP (exit 0), output identical to the reference run, 10 questions each.
  - **"Finished when" fully met: 20 queries return correct results AND the schema rejects bad data.**
  - **Milestone 4 complete** (understanding check not asked; learner opted out of tutor mode for the queries).
  - M4 commit step given: `git add sql/04_queries_1_10.sql TUTOR_PROGRESS.md`, commit "Milestone 4: business queries 1-10 (SELECT, WHERE, JOINs, GROUP BY, HAVING)", push. Asked how to do the README.

  - M4 commit `cb4dba1` pushed. Learner said "done" without choosing full/steps for the README → went with full (it mostly repeats the queries).
  - README built in the scratchpad (`README.md`, 364 lines): header written by Claude + the 20 queries extracted from the learner's own .sql files with an awk script (no retyping). Learner copies it into the repo with `Copy-Item` (they run it) and reviews it in VS Code preview.
  - M5 final step given: copy README, preview, `git add sql/05_queries_11_20.sql README.md TUTOR_PROGRESS.md`, commit "Milestone 5: business queries 11-20 and README", push, check on GitHub (mermaid diagram renders).

## Next
- Waiting for "done". Verify: README.md in repo matches the scratchpad copy, 5 commits, origin/main matches, working tree clean.
- Then: **project complete**. Offer (once) a short review quiz; suggest optional extras (e.g. indexes on FK columns, a book_authors junction table, a view for order totals) only if asked. New file `sql/03_bad_data_tests.sql` (run with `\i`, without ON_ERROR_STOP, so each failure prints and the next test runs). Tests: negative price, price 0, ISBN with a dash, unknown author_id 99, stock -1. Each expects ERROR naming its constraint. Explain reading an error (ERROR line, DETAIL line, constraint name).
- Then: M3 · Step 8: part 2: duplicate email, bad email, status 'lost', shipped before ordered, quantity 0, duplicate (order, book), delete a sold book (FK refuses), delete an order (CASCADE removes lines — wrap in BEGIN/ROLLBACK so data stays).
