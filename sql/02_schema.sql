-- 02_schema.sql - Milestone 2
-- Creates the bookstore tables in the shop schema.
-- Run from psql:  \i /sql/02_schema.sql

-- Work in the bookstore database as its owner, so the tables
-- land in the shop schema and belong to bookstore_app.
\connect bookstore bookstore_app

-- DESIGN: each fact is stored in exactly one table.
--
-- Tables and their columns (PK = primary key, FK = foreign key):
--   authors      author_id PK, first_name, last_name, country
--   books        book_id PK, title, isbn, genre, price,
--                published_year, stock, author_id FK -> authors
--   customers    customer_id PK, first_name, last_name, email,
--                city, joined_on
--   orders       order_id PK, order_date, shipped_date, status,
--                customer_id FK -> customers
--   order_items  order_id FK -> orders, book_id FK -> books,
--                quantity, unit_price
--                PK = (order_id, book_id)
--
-- Relationships (1 --< many):
--   authors   1 --< books        one author writes many books
--   customers 1 --< orders       one customer places many orders
--   orders    1 --< order_items  one order has many lines
--   books     1 --< order_items  one book appears on many lines
--
-- Choices:
--   - One author per book, to keep it simple.
--   - order_items.unit_price is the price paid on that day.
--     books.price can change later; old orders must not.

-- Start clean, so the file can be run again after a mistake.
-- Children first: a table can't be dropped while others point to it.
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;

-- Authors: one row per person who writes books.
CREATE TABLE authors (
    author_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name  text NOT NULL,
    last_name   text NOT NULL,
    country     text
);

-- Books: one row per title the store sells.
CREATE TABLE books (
    book_id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title           text NOT NULL,
    isbn            text NOT NULL UNIQUE
                    CHECK (isbn ~ '^[0-9]{13}$'),
    genre           text,
    price           numeric(8, 2) NOT NULL CHECK (price > 0),
    published_year  integer CHECK (published_year BETWEEN 1450 AND 2100),
    stock           integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
    author_id       integer NOT NULL REFERENCES authors (author_id)
);

-- Customers: one row per person who buys from the store.
CREATE TABLE customers (
    customer_id  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name   text NOT NULL,
    last_name    text NOT NULL,
    email        text NOT NULL UNIQUE
                 CHECK (email LIKE '%_@_%._%'),
    city         text,
    joined_on    date NOT NULL DEFAULT current_date
);

-- Orders: one row per purchase. The books in it are in order_items.
CREATE TABLE orders (
    order_id      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id   integer NOT NULL REFERENCES customers (customer_id),
    order_date    date NOT NULL DEFAULT current_date,
    shipped_date  date,
    status        text NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'shipped',
                                    'delivered', 'cancelled')),
    -- A rule that compares two columns goes after the columns.
    CONSTRAINT shipped_after_ordered
        CHECK (shipped_date >= order_date)
);

-- Order items: one row per book in an order (the junction table).
CREATE TABLE order_items (
    order_id    integer REFERENCES orders (order_id) ON DELETE CASCADE,
    book_id     integer REFERENCES books (book_id),
    quantity    integer NOT NULL CHECK (quantity > 0),
    unit_price  numeric(8, 2) NOT NULL CHECK (unit_price > 0),
    -- The same book can appear only once per order.
    PRIMARY KEY (order_id, book_id)
);
