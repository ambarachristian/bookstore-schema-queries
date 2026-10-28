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
9. Commit and push.

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

## Next
- Waiting for "done" on M2 · Step 9. Verify `git log --oneline` (2 commits), `git status` clean apart from TUTOR_PROGRESS.md, origin/main matches.
- Then: Milestone 2 complete → M3 · Step 1 (INSERT authors).
