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
8. Commit with git.
9. Create a public GitHub repo and push.

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

## Next
- Waiting for "done" on M1 · Step 8. Verify with `git status`, `git log --oneline`, `git ls-files` (expect 4 files; empty `data/` is not tracked).
- Then: M1 · Step 9: `gh repo create bookstore-schema-queries --public --source=. --remote=origin --push`, then check with `git remote -v`, `git status` ("up to date with 'origin/main'"), and open the repo in the browser (`gh repo view --web`).
- Then: M1 complete → M1 understanding questions as warm-up → M2 · Step 1 (normalization, then authors table).
