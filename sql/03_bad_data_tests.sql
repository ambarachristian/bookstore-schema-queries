-- 03_bad_data_tests.sql - Milestone 3
-- Each statement below breaks one rule on purpose.
-- Every one must FAIL with an ERROR that names the rule.
-- Run from psql:  \i /sql/03_bad_data_tests.sql   (after 03_data.sql)

\connect bookstore bookstore_app

\echo '=== Test 1: negative price (expect books_price_check)'
INSERT INTO books (title, isbn, price, author_id)
    VALUES ('Bad Price', '9780000000001', -5.00, 1);

\echo '=== Test 2: price of zero (expect books_price_check)'
INSERT INTO books (title, isbn, price, author_id)
    VALUES ('Free Book', '9780000000002', 0, 1);

\echo '=== Test 3: ISBN with a dash (expect books_isbn_check)'
INSERT INTO books (title, isbn, price, author_id)
    VALUES ('Bad ISBN', '978-000000003', 9.99, 1);

\echo '=== Test 4: ISBN already used (expect books_isbn_key)'
INSERT INTO books (title, isbn, price, author_id)
    VALUES ('Copycat', '9780385474542', 9.99, 1);

\echo '=== Test 5: author that does not exist (expect books_author_id_fkey)'
INSERT INTO books (title, isbn, price, author_id)
    VALUES ('Ghost Author', '9780000000005', 9.99, 99);

\echo '=== Test 6: missing title (expect a not-null error on title)'
INSERT INTO books (isbn, price, author_id)
    VALUES ('9780000000006', 9.99, 1);

\echo '=== Test 7: negative stock (expect books_stock_check)'
UPDATE books SET stock = -1 WHERE book_id = 1;

\echo '=== Test 8: email already used (expect customers_email_key)'
INSERT INTO customers (first_name, last_name, email)
    VALUES ('Aïcha', 'Copy', 'aicha.bello@example.com');

\echo '=== Test 9: email without @ (expect customers_email_check)'
INSERT INTO customers (first_name, last_name, email)
    VALUES ('No', 'Email', 'not-an-email');

\echo '=== Test 10: unknown status (expect orders_status_check)'
INSERT INTO orders (customer_id, status) VALUES (1, 'lost');

\echo '=== Test 11: shipped before ordered (expect shipped_after_ordered)'
INSERT INTO orders (customer_id, order_date, shipped_date, status)
    VALUES (1, '2026-10-10', '2026-10-01', 'shipped');

\echo '=== Test 12: customer that does not exist (expect orders_customer_id_fkey)'
INSERT INTO orders (customer_id) VALUES (99);

\echo '=== Test 13: quantity of zero (expect order_items_quantity_check)'
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
    VALUES (1, 4, 0, 8.99);

\echo '=== Test 14: same book twice in one order (expect order_items_pkey)'
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
    VALUES (1, 1, 1, 12.99);

\echo '=== Test 15: delete a book that was sold (expect order_items_book_id_fkey)'
DELETE FROM books WHERE book_id = 13;

\echo '=== Test 16: delete an author who has books (expect books_author_id_fkey)'
DELETE FROM authors WHERE author_id = 1;

\echo '=== After the tests: counts must still be 9, 21, 12, 25, 38'
SELECT 'authors' AS table_name, count(*) FROM authors
UNION ALL SELECT 'books',       count(*) FROM books
UNION ALL SELECT 'customers',   count(*) FROM customers
UNION ALL SELECT 'orders',      count(*) FROM orders
UNION ALL SELECT 'order_items', count(*) FROM order_items;
