-- 03_data.sql - Milestone 3
-- Loads sample data into the bookstore tables.
-- Run from psql:  \i /sql/03_data.sql   (after 01 and 02)

\connect bookstore bookstore_app

-- Start clean: empty all five tables and restart the ID counters at 1,
-- so the file can be run again and the IDs stay the same every time.
TRUNCATE order_items, orders, customers, books, authors
    RESTART IDENTITY;

-- Authors. author_id is left out: PostgreSQL numbers them 1, 2, 3...
-- Toni Morrison has no books in the store yet.
-- Amina Diallo is a new local author; her country is unknown.
INSERT INTO authors (first_name, last_name, country) VALUES
    ('Chinua',           'Achebe',          'Nigeria'),
    ('Jane',             'Austen',          'United Kingdom'),
    ('Gabriel',          'García Márquez',  'Colombia'),
    ('Chimamanda Ngozi', 'Adichie',         'Nigeria'),
    ('George',           'Orwell',          'United Kingdom'),
    ('Haruki',           'Murakami',        'Japan'),
    ('Mongo',            'Beti',            'Cameroon'),
    ('Toni',             'Morrison',        'United States'),
    ('Amina',            'Diallo',          NULL);

-- Books come from a CSV file. book_id is left out, so it's numbered 1, 2, 3...
-- Emma is out of stock. Harmattan Letters has no publication year yet.
\copy books (title, isbn, genre, price, published_year, stock, author_id) FROM '/data/books.csv' WITH (FORMAT csv, HEADER true)

-- Customers. Thomas Wright and Brigitte Ateba joined recently and
-- have not ordered yet. Brigitte Ateba's city is unknown.
INSERT INTO customers (first_name, last_name, email, city, joined_on) VALUES
    ('Aïcha',     'Bello',    'aicha.bello@example.com',     'Douala',  '2025-01-14'),
    ('Jean-Paul', 'Mbarga',   'jeanpaul.mbarga@example.com', 'Yaoundé', '2025-02-03'),
    ('Chidi',     'Okafor',   'chidi.okafor@example.com',    'Lagos',   '2025-03-22'),
    ('Claire',    'Dubois',   'claire.dubois@example.com',   'Paris',   '2025-04-10'),
    ('Liam',      'O''Brien', 'liam.obrien@example.com',     'London',  '2025-05-18'),
    ('Fatima',    'Njoya',    'fatima.njoya@example.com',    'Douala',  '2025-07-01'),
    ('Emeka',     'Eze',      'emeka.eze@example.com',       'Lagos',   '2025-09-09'),
    ('Sophie',    'Martin',   'sophie.martin@example.com',   'Paris',   '2025-11-25'),
    ('Samuel',    'Etoga',    'samuel.etoga@example.com',    'Yaoundé', '2026-01-12'),
    ('Grace',     'Adeyemi',  'grace.adeyemi@example.com',   'Lagos',   '2026-04-30'),
    ('Thomas',    'Wright',   'thomas.wright@example.com',   'London',  '2026-08-15'),
    ('Brigitte',  'Ateba',    'brigitte.ateba@example.com',  NULL,      '2026-10-02');

-- Orders, numbered 1-25 in this order. Pending and cancelled orders
-- have no shipped_date. Customers 11 and 12 have no orders.
INSERT INTO orders (customer_id, order_date, shipped_date, status) VALUES
    (1,  '2025-02-10', '2025-02-12', 'delivered'),
    (2,  '2025-03-05', '2025-03-08', 'delivered'),
    (1,  '2025-04-18', '2025-04-21', 'delivered'),
    (3,  '2025-05-02', '2025-05-06', 'delivered'),
    (4,  '2025-06-14', '2025-06-16', 'delivered'),
    (2,  '2025-07-20', NULL,         'cancelled'),
    (5,  '2025-08-03', '2025-08-05', 'delivered'),
    (3,  '2025-09-15', '2025-09-19', 'delivered'),
    (6,  '2025-10-01', '2025-10-03', 'delivered'),
    (1,  '2025-11-11', '2025-11-14', 'delivered'),
    (7,  '2025-12-02', '2025-12-09', 'delivered'),
    (4,  '2025-12-20', '2025-12-22', 'delivered'),
    (8,  '2026-01-08', '2026-01-10', 'delivered'),
    (3,  '2026-02-14', '2026-02-17', 'delivered'),
    (9,  '2026-03-03', '2026-03-05', 'delivered'),
    (6,  '2026-04-22', NULL,         'cancelled'),
    (1,  '2026-05-30', '2026-06-02', 'delivered'),
    (10, '2026-06-18', '2026-06-20', 'delivered'),
    (5,  '2026-07-25', '2026-07-28', 'delivered'),
    (3,  '2026-08-30', '2026-09-02', 'delivered'),
    (7,  '2026-09-21', '2026-09-24', 'delivered'),
    (9,  '2026-10-12', '2026-10-15', 'shipped'),
    (1,  '2026-10-20', '2026-10-22', 'shipped'),
    (10, '2026-10-25', NULL,         'pending'),
    (2,  '2026-10-27', NULL,         'pending');

-- Order items come from a CSV file: which book, how many, price paid.
-- Orders 1, 4 and 6 paid an older price. Books 3, 15 and 21 never sold.
\copy order_items (order_id, book_id, quantity, unit_price) FROM '/data/order_items.csv' WITH (FORMAT csv, HEADER true)

-- Quick check: how many rows each table has after loading.
SELECT 'authors' AS table_name, count(*) FROM authors
UNION ALL SELECT 'books',       count(*) FROM books
UNION ALL SELECT 'customers',   count(*) FROM customers
UNION ALL SELECT 'orders',      count(*) FROM orders
UNION ALL SELECT 'order_items', count(*) FROM order_items;
