-- 01_setup.sql - Milestone 1
-- Creates the role and database for the bookstore project.
-- Run from psql as postgres:  \i /sql/01_setup.sql
-- WARNING: this deletes the bookstore database and everything in it,
-- then builds it again from zero.
-- Always start in the postgres database as the postgres role.
-- (You can't delete a database while you're connected to it.)
\connect postgres postgres


-- Start clean, so the file can be run again after a mistake.
DROP DATABASE IF EXISTS bookstore;
DROP ROLE IF EXISTS bookstore_app;

-- An account for the project. LOGIN lets it connect.
CREATE ROLE bookstore_app
    LOGIN
    PASSWORD 'bookstore_dev_pw';

-- The project's database, owned by the new role.
CREATE DATABASE bookstore
    OWNER bookstore_app;

-- Move into the new database, logged in as its owner.
\connect bookstore bookstore_app

-- A schema for the bookstore's tables. Its owner is bookstore_app.
CREATE SCHEMA shop;

-- Where PostgreSQL looks for a table when you don't name its schema.
-- Applies to every new connection to this database.
ALTER DATABASE bookstore SET search_path = shop, public;
