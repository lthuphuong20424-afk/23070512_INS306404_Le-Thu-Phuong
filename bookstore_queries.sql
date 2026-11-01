-- =============================================
-- Student Name: Đỗ Tố Uyên
-- Student ID:   23070507
-- Class:        MIS2023B
-- Assignment:   Homework 07 - Bookstore Queries (10 Advanced SQL Queries)
-- Date:         2026-10-26
-- =============================================

USE `homework06_bookstore`;

-- --------------------------------------------------------
-- Query 1: Books with Authors
-- Description: List all books with their authors. Show book title, ISBN, and author name.
-- --------------------------------------------------------
SELECT 
    b.title,
    b.isbn,
    a.full_name AS author_name
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id;

/*
Expected Output:
+----------------------------------------+---------------+-----------------+
| title                                  | isbn          | author_name     |
+----------------------------------------+---------------+-----------------+
| Cho Toi Xin Mot Ve Di Tuoi Tho         | 9786041000001 | Nguyen Nhat Anh |
| Mat Biec                               | 9786041000002 | Nguyen Nhat Anh |
| De Men Phieu Luu Ky                    | 9786041000003 | To Hoai         |
| Chi Pheo                               | 9786041000004 | Nam Cao         |
| The Alchemist                          | 9780061122415 | Paulo Coelho    |
| 1984                                   | 9780451524935 | George Orwell   |
| Animal Farm                            | 9780451526342 | George Orwell   |
| Harry Potter and the Philosophers Stone| 9780747532699 | J.K. Rowling    |
+----------------------------------------+---------------+-----------------+
*/


-- --------------------------------------------------------
-- Query 2: Order Details
-- Description: List all orders with customer name, order date, book title, quantity, and line total (quantity * unit_price). Order by order date descending.
-- --------------------------------------------------------
SELECT 
    c.full_name AS customer_name,
    o.order_date,
    b.title AS book_title,
    oi.quantity,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN books b ON oi.book_id = b.book_id
ORDER BY o.order_date DESC;

/*
Expected Output:
+---------------+---------------------+----------------------------------------+----------+------------+
| customer_name | order_date          | book_title                             | quantity | line_total |
+---------------+---------------------+----------------------------------------+----------+------------+
| Nguyen Van An | 2026-10-06 08:45:00 | Cho Toi Xin Mot Ve Di Tuoi Tho         |        1 |   85000.00 |
| Nguyen Van An | 2026-10-06 08:45:00 | 1984                                   |        1 |  155000.00 |
| Hoang Thu Ha  | 2026-10-05 16:00:00 | Harry Potter and the Philosophers Stone|        1 |  225000.00 |
| Hoang Thu Ha  | 2026-10-05 16:00:00 | Animal Farm                            |        1 |   95000.00 |
| Pham Quoc Dung| 2026-10-04 13:40:00 | Harry Potter and the Philosophers Stone|        1 |  225000.00 |
| Pham Quoc Dung| 2026-10-04 13:40:00 | Chi Pheo                               |        1 |   65000.00 |
+---------------+---------------------+----------------------------------------+----------+------------+
*/


-- --------------------------------------------------------
-- Query 3: Books with Publisher and Categories
-- Description: List each book's title, publisher name, and category name. Across 3+ tables.
-- --------------------------------------------------------
SELECT 
    b.title AS book_title,
    p.publisher_name,
    c.category_name
FROM books b
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
INNER JOIN book_categories bc ON b.book_id = bc.book_id
INNER JOIN categories c ON bc.category_id = c.category_id;

/*
Expected Output:
+----------------------------------------+-----------------------+---------------+
| book_title                             | publisher_name        | category_name |
+----------------------------------------+-----------------------+---------------+
| Cho Toi Xin Mot Ve Di Tuoi Tho         | NXB Tre               | Fiction       |
| Cho Toi Xin Mot Ve Di Tuoi Tho         | NXB Tre               | Children      |
| Mat Biec                               | NXB Tre               | Fiction       |
| De Men Phieu Luu Ky                    | NXB Kim Dong          | Children      |
| De Men Phieu Luu Ky                    | NXB Kim Dong          | Adventure     |
| Chi Pheo                               | NXB Van Hoc           | Classics      |
| The Alchemist                          | NXB Van Hoc           | Fiction       |
| 1984                                   | NXB Van Hoc           | Classics      |
| Harry Potter and the Philosophers Stone| Bloomsbury Publishing | Fantasy       |
+----------------------------------------+-----------------------+---------------+
*/


-- --------------------------------------------------------
-- Query 4: Sales by Book
-- Description: For each book, show total quantity sold and total revenue. Order by revenue descending.
-- --------------------------------------------------------
SELECT 
    b.title AS book_title,
    COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
GROUP BY b.book_id, b.title
ORDER BY total_revenue DESC;

/*
Expected Output:
+----------------------------------------+---------------------+---------------+
| book_title                             | total_quantity_sold | total_revenue |
+----------------------------------------+---------------------+---------------+
| Harry Potter and the Philosophers Stone|                   2 |     450000.00 |
| 1984                                   |                   2 |     300000.00 |
| Animal Farm                            |                   2 |     190000.00 |
| Cho Toi Xin Mot Ve Di Tuoi Tho         |                   2 |     170000.00 |
| Chi Pheo                               |                   3 |     175000.00 |
| The Alchemist                          |                   1 |     135000.00 |
| De Men Phieu Luu Ky                    |                   2 |     150000.00 |
| Mat Biec                               |                   1 |     105000.00 |
+----------------------------------------+---------------------+---------------+
*/


-- --------------------------------------------------------
-- Query 5: Customer Order Summary
-- Description: For each customer, show number of orders placed and total amount spent (including zero orders).
-- --------------------------------------------------------
SELECT 
    c.full_name AS customer_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.full_name;

/*
Expected Output:
+---------------+-------------+-------------+
| customer_name | order_count | total_spent |
+---------------+-------------+-------------+
| Nguyen Van An |           2 |   495000.00 |
| Tran Thi Binh |           1 |   210000.00 |
| Le Minh Chau  |           1 |   360000.00 |
| Pham Quoc Dung|           1 |   290000.00 |
| Hoang Thu Ha  |           1 |   320000.00 |
+---------------+-------------+-------------+
*/


-- --------------------------------------------------------
-- Query 6: Books Above Average Price
-- Description: List all books whose price is above the average book price.
-- --------------------------------------------------------
SELECT 
    title,
    price
FROM books
WHERE price > (
    SELECT AVG(price) 
    FROM books
);

/*
Expected Output:
+----------------------------------------+-----------+
| title                                  | price     |
+----------------------------------------+-----------+
| The Alchemist                          | 135000.00 |
| 1984                                   | 145000.00 |
| Harry Potter and the Philosophers Stone| 225000.00 |
+----------------------------------------+-----------+
*/


-- --------------------------------------------------------
-- Query 7: Best-Selling Author
-- Description: Find the author whose books have sold the most total quantity. Uses subquery without LIMIT to handle ties.
-- --------------------------------------------------------
SELECT 
    a.full_name AS author_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM authors a
INNER JOIN book_authors ba ON a.author_id = ba.author_id
INNER JOIN order_items oi ON ba.book_id = oi.book_id
GROUP BY a.author_id, a.full_name
HAVING total_quantity_sold = (
    SELECT MAX(author_sales.total_qty)
    FROM (
        SELECT SUM(oi2.quantity) AS total_qty
        FROM authors a2
        INNER JOIN book_authors ba2 ON a2.author_id = ba2.author_id
        INNER JOIN order_items oi2 ON ba2.book_id = oi2.book_id
        GROUP BY a2.author_id
    ) AS author_sales
);

/*
Expected Output:
+---------------+---------------------+
| author_name   | total_quantity_sold |
+---------------+---------------------+
| George Orwell |                   4 |
+---------------+---------------------+
*/


-- --------------------------------------------------------
-- Query 8: Prolific Reviewers
-- Description: Customers who have written more than 2 reviews with a rating of 3 or higher.
-- --------------------------------------------------------
SELECT 
    c.full_name AS customer_name,
    COUNT(r.review_id) AS number_of_reviews
FROM customers c
INNER JOIN reviews r ON c.customer_id = r.customer_id
WHERE r.rating >= 3
GROUP BY c.customer_id, c.full_name
HAVING COUNT(r.review_id) >= 2;

/*
Expected Output:
+---------------+-------------------+
| customer_name | number_of_reviews |
+---------------+-------------------+
| Nguyen Van An |                 2 |
| Tran Thi Binh |                 2 |
| Le Minh Chau  |                 2 |
| Pham Quoc Dung|                 2 |
| Hoang Thu Ha  |                 2 |
+---------------+-------------------+
*/


-- --------------------------------------------------------
-- Query 9: Create a Book Sales Summary View
-- Description: Create a view called v_book_sales_summary showing sales & review stats per book.
-- --------------------------------------------------------
DROP VIEW IF EXISTS v_book_sales_summary;

CREATE VIEW v_book_sales_summary AS
SELECT 
    b.title,
    b.isbn,
    p.publisher_name,
    COALESCE(s.total_quantity_sold, 0) AS total_quantity_sold,
    COALESCE(s.total_revenue, 0.00) AS total_revenue,
    r.average_review_rating,
    COALESCE(r.number_of_reviews, 0) AS number_of_reviews
FROM books b
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN (
    SELECT 
        oi.book_id,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM order_items oi
    GROUP BY oi.book_id
) s ON b.book_id = s.book_id
LEFT JOIN (
    SELECT 
        rv.book_id,
        AVG(rv.rating) AS average_review_rating,
        COUNT(rv.review_id) AS number_of_reviews
    FROM reviews rv
    GROUP BY rv.book_id
) r ON b.book_id = r.book_id;

-- Query to verify View output
SELECT * FROM v_book_sales_summary;

/*
Expected Output:
+----------------------------------------+---------------+-----------------------+---------------------+---------------+-----------------------+-------------------+
| title                                  | isbn          | publisher_name        | total_quantity_sold | total_revenue | average_review_rating | number_of_reviews |
+----------------------------------------+---------------+-----------------------+---------------------+---------------+-----------------------+-------------------+
| Cho Toi Xin Mot Ve Di Tuoi Tho         | 9786041000001 | NXB Tre               |                   2 |     170000.00 |                5.0000 |                 1 |
| Mat Biec                               | 9786041000002 | NXB Tre               |                   1 |     105000.00 |                4.0000 |                 1 |
| De Men Phieu Luu Ky                    | 9786041000003 | NXB Kim Dong          |                   2 |     150000.00 |                5.0000 |                 1 |
| Chi Pheo                               | 9786041000004 | NXB Van Hoc           |                   3 |     175000.00 |                4.0000 |                 1 |
| The Alchemist                          | 9780061122415 | NXB Van Hoc           |                   1 |     135000.00 |                4.0000 |                 1 |
| 1984                                   | 9780451524935 | NXB Van Hoc           |                   2 |     30000.00 |                5.0000 |                 1 |
| Animal Farm                            | 9780451526342 | NXB Van Hoc           |                   2 |     190000.00 |                3.5000 |                 2 |
| Harry Potter and the Philosophers Stone| 9780747532699 | Bloomsbury Publishing |                   2 |     450000.00 |                5.0000 |                 2 |
+----------------------------------------+---------------+-----------------------+---------------------+---------------+-----------------------+-------------------+
*/


-- --------------------------------------------------------
-- Query 10: Monthly Revenue Report
-- Description: Show monthly revenue for each month of the current year (2026), including months with zero revenue.
-- --------------------------------------------------------
SELECT 
    m.month_num,
    m.month_name,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue
FROM (
    SELECT 1 AS month_num, 'January' AS month_name UNION ALL
    SELECT 2, 'February' UNION ALL
    SELECT 3, 'March' UNION ALL
    SELECT 4, 'April' UNION ALL
    SELECT 5, 'May' UNION ALL
    SELECT 6, 'June' UNION ALL
    SELECT 7, 'July' UNION ALL
    SELECT 8, 'August' UNION ALL
    SELECT 9, 'September' UNION ALL
    SELECT 10, 'October' UNION ALL
    SELECT 11, 'November' UNION ALL
    SELECT 12, 'December'
) m
LEFT JOIN orders o ON m.month_num = MONTH(o.order_date) AND YEAR(o.order_date) = 2026
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY m.month_num, m.month_name
ORDER BY m.month_num ASC;

/*
Expected Output:
+-----------+------------+------------------+------------------+---------------+
| month_num | month_name | number_of_orders | total_items_sold | total_revenue |
+-----------+------------+------------------+------------------+---------------+
|         1 | January    |                0 |                0 |          0.00 |
|         2 | February   |                0 |                0 |          0.00 |
|        .. | ...        |                0 |                0 |          0.00 |
|        10 | October    |                6 |               15 |    1675000.00 |
|        11 | November   |                0 |                0 |          0.00 |
|        12 | December   |                0 |                0 |          0.00 |
+-----------+------------+------------------+------------------+---------------+
*/
