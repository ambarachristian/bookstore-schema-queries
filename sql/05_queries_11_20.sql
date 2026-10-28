-- 05_queries_11_20.sql - Milestone 5
-- Business questions 11-20: subqueries, EXISTS, CASE, date arithmetic.
-- Run from psql:  \i /sql/05_queries_11_20.sql   (after 01, 02 and 03)
-- "Sold" means the order was shipped or delivered (not pending or cancelled).

\connect bookstore bookstore_app

-- The sample data ends on 2026-10-28. Date questions use this fixed
-- "as of" date, so the answers are the same whenever you run the file.
-- With live data, use current_date instead of :'as_of'::date.
\set as_of '2026-10-28'

\echo '=== Q11. Which books cost more than the average book?'
SELECT title, price
FROM books
WHERE price > (SELECT avg(price) FROM books)
ORDER BY price DESC;

\echo '=== Q12. Which books have never been ordered?'
SELECT title, stock
FROM books
WHERE book_id NOT IN (SELECT book_id FROM order_items)
ORDER BY title;

\echo '=== Q13. Which customers bought at least one book by a Nigerian author?'
SELECT first_name || ' ' || last_name AS customer, city
FROM customers
WHERE customer_id IN (
    SELECT o.customer_id
    FROM orders AS o
    JOIN order_items AS oi ON oi.order_id = o.order_id
    JOIN books       AS b  ON b.book_id   = oi.book_id
    JOIN authors     AS a  ON a.author_id = b.author_id
    WHERE a.country = 'Nigeria'
      AND o.status IN ('shipped', 'delivered')
)
ORDER BY customer;

\echo '=== Q14. Which customers have never placed an order?'
SELECT first_name || ' ' || last_name AS customer, email, joined_on
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM orders AS o WHERE o.customer_id = c.customer_id
)
ORDER BY joined_on;

\echo '=== Q15. Which customers placed an order in the last 30 days?'
SELECT first_name || ' ' || last_name AS customer, city
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.order_date > :'as_of'::date - 30
)
ORDER BY customer;

\echo '=== Q16. How many titles are out of stock, low, or well stocked?'
SELECT CASE
           WHEN stock = 0 THEN 'out of stock'
           WHEN stock < 5 THEN 'low (1-4)'
           ELSE 'ok (5+)'
       END AS stock_level,
       count(*) AS titles
FROM books
GROUP BY stock_level
ORDER BY min(stock);

\echo '=== Q17. Which loyalty tier is each customer in, based on total spent?'
SELECT c.first_name || ' ' || c.last_name AS customer,
       coalesce(sum(oi.quantity * oi.unit_price), 0) AS total_spent,
       CASE
           WHEN sum(oi.quantity * oi.unit_price) >= 100 THEN 'gold'
           WHEN sum(oi.quantity * oi.unit_price) >= 40  THEN 'silver'
           WHEN sum(oi.quantity * oi.unit_price) >  0   THEN 'bronze'
           ELSE 'new'
       END AS tier
FROM customers AS c
LEFT JOIN orders AS o
       ON o.customer_id = c.customer_id
      AND o.status IN ('shipped', 'delivered')
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC, customer;

\echo '=== Q18. How many days does shipping take, per year?'
SELECT extract(year FROM order_date)            AS year,
       count(*)                                 AS shipped_orders,
       round(avg(shipped_date - order_date), 1) AS avg_days,
       max(shipped_date - order_date)           AS slowest_days
FROM orders
WHERE shipped_date IS NOT NULL
GROUP BY year
ORDER BY year;

\echo '=== Q19. Which orders are still open, and how many days old are they?'
SELECT o.order_id,
       c.first_name || ' ' || c.last_name AS customer,
       o.status,
       o.order_date,
       :'as_of'::date - o.order_date AS days_old
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
WHERE o.status IN ('pending', 'shipped')
ORDER BY days_old DESC;

\echo '=== Q20. How much revenue did each month of 2026 bring in?'
SELECT to_char(o.order_date, 'YYYY-MM')  AS month,
       count(DISTINCT o.order_id)        AS orders,
       sum(oi.quantity * oi.unit_price)  AS revenue
FROM orders AS o
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status IN ('shipped', 'delivered')
  AND o.order_date >= '2026-01-01'
  AND o.order_date <  '2027-01-01'
GROUP BY month
ORDER BY month;
