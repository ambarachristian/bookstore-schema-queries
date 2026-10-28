-- 04_queries_1_10.sql - Milestone 4
-- Business questions 1-10: SELECT, WHERE, ORDER BY, JOINs, GROUP BY, HAVING.
-- Run from psql:  \i /sql/04_queries_1_10.sql   (after 01, 02 and 03)
-- "Sold" means the order was shipped or delivered (not pending or cancelled).

\connect bookstore bookstore_app

\echo '=== Q1. What does the store sell, from most to least expensive?'
SELECT title, genre, price
FROM books
ORDER BY price DESC, title;

\echo '=== Q2. Which books are running low (fewer than 5 copies), most urgent first?'
SELECT title, stock, price
FROM books
WHERE stock < 5
ORDER BY stock, title;

\echo '=== Q3. Which customers in Lagos or Douala joined during 2025?'
SELECT first_name, last_name, city, joined_on
FROM customers
WHERE city IN ('Lagos', 'Douala')
  AND joined_on >= '2025-01-01'
  AND joined_on <  '2026-01-01'
ORDER BY joined_on;

\echo '=== Q4. Who wrote each book? (INNER JOIN)'
SELECT a.first_name || ' ' || a.last_name AS author,
       b.title,
       b.published_year
FROM books AS b
JOIN authors AS a ON a.author_id = b.author_id
ORDER BY a.last_name, b.published_year;

\echo '=== Q5. What did Chidi Okafor buy, and what did each line cost?'
SELECT o.order_id,
       o.order_date,
       b.title,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM customers AS c
JOIN orders      AS o  ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id   = o.order_id
JOIN books       AS b  ON b.book_id     = oi.book_id
WHERE c.email = 'chidi.okafor@example.com'
ORDER BY o.order_date, b.title;

\echo '=== Q6. Which authors have no books in the store yet? (LEFT JOIN)'
SELECT a.first_name || ' ' || a.last_name AS author,
       a.country
FROM authors AS a
LEFT JOIN books AS b ON b.author_id = a.author_id
WHERE b.book_id IS NULL
ORDER BY author;

\echo '=== Q7. How many titles does each genre have, and at what average price?'
SELECT genre,
       count(*)             AS titles,
       round(avg(price), 2) AS avg_price
FROM books
GROUP BY genre
ORDER BY titles DESC, genre;

\echo '=== Q8. How much revenue has each genre brought in?'
SELECT b.genre,
       sum(oi.quantity * oi.unit_price) AS revenue
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
JOIN books  AS b ON b.book_id  = oi.book_id
WHERE o.status IN ('shipped', 'delivered')
GROUP BY b.genre
ORDER BY revenue DESC;

\echo '=== Q9. Which customers have spent more than 50 in total?'
SELECT c.first_name || ' ' || c.last_name AS customer,
       count(DISTINCT o.order_id)          AS orders,
       sum(oi.quantity * oi.unit_price)    AS total_spent
FROM customers AS c
JOIN orders      AS o  ON o.customer_id = c.customer_id
JOIN order_items AS oi ON oi.order_id   = o.order_id
WHERE o.status IN ('shipped', 'delivered')
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING sum(oi.quantity * oi.unit_price) > 50
ORDER BY total_spent DESC;

\echo '=== Q10. What are the 5 best-selling books by copies sold?'
SELECT b.title,
       sum(oi.quantity) AS copies_sold
FROM order_items AS oi
JOIN orders AS o ON o.order_id = oi.order_id
JOIN books  AS b ON b.book_id  = oi.book_id
WHERE o.status IN ('shipped', 'delivered')
GROUP BY b.book_id, b.title
ORDER BY copies_sold DESC, b.title
LIMIT 5;
