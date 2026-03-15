
use projects;
-- 1. Books table
CREATE TABLE Books (
    book_id INTEGER PRIMARY KEY,
    title TEXT,
    genre TEXT,
    price DECIMAL(6,2),
    stock INTEGER
);

-- 2. Customers table
CREATE TABLE Customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    city TEXT,
    signup_date DATE
);

-- 3. Orders table
CREATE TABLE Orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    book_id INTEGER,
    quantity INTEGER,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- 4. MarketingSpend table
CREATE TABLE MarketingSpend (
    spend_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    spend_amount DECIMAL(7,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
-- Books
INSERT INTO Books VALUES
(1, 'Data Science 101', 'Education', 29.99, 100),
(2, 'The Art of SQL', 'Technology', 34.50, 50),
(3, 'Mystery at the Bookstore', 'Fiction', 15.00, 20),
(4, 'Learn Python the Hard Way', 'Education', 40.00, 30),
(5, 'Fantasy World Chronicles', 'Fantasy', 22.50, 10);

-- Customers
INSERT INTO Customers VALUES
(1, 'Alice', 'New York', '2023-01-10'),
(2, 'Bob', 'San Francisco', '2023-03-15'),
(3, 'Charlie', 'Austin', '2023-06-20'),
(4, 'Diana', 'New York', '2024-01-10'),
(5, 'Evan', 'Chicago', '2024-04-05');

-- Orders
INSERT INTO Orders VALUES
(1, 1, 1, 2, '2024-06-01'),
(2, 2, 2, 1, '2024-06-02'),
(3, 1, 3, 1, '2024-06-03'),
(4, 3, 1, 3, '2024-06-04'),
(5, 4, 5, 2, '2024-06-04'),
(6, 5, 2, 2, '2024-06-05'),
(7, 2, 4, 1, '2024-06-05'),
(8, 1, 1, 1, '2024-06-06');

-- Marketing Spend
INSERT INTO MarketingSpend VALUES
(1, 1, 50.00),
(2, 2, 75.00),
(3, 3, 40.00),
(4, 4, 60.00),
(5, 5, 35.00);
SELECT 
    b.title,
    SUM(o.quantity) AS total_units_sold,
    SUM(o.quantity * b.price) AS total_revenue
FROM Orders o
JOIN Books b ON o.book_id = b.book_id
GROUP BY b.title
ORDER BY total_revenue DESC;
SELECT 
    title, stock
FROM Books
WHERE stock < 15;
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.name,
        MAX(order_date) AS last_order,
        COUNT(o.order_id) AS frequency,
        SUM(o.quantity * b.price) AS monetary
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN Books b ON o.book_id = b.book_id
    GROUP BY c.customer_id
)
SELECT *,
       julianday('2024-07-01') - julianday(last_order) AS recency_days
FROM customer_metrics;
WITH customer_spend AS (
    SELECT 
        o.customer_id,
        SUM(o.quantity * b.price) AS total_revenue
    FROM Orders o
    JOIN Books b ON o.book_id = b.book_id
    GROUP BY o.customer_id
)
SELECT 
    c.customer_id,
    c.name,
    ms.spend_amount,
    cs.total_revenue,
    (cs.total_revenue - ms.spend_amount) AS profit
FROM Customers c
JOIN MarketingSpend ms ON c.customer_id = ms.customer_id
JOIN customer_spend cs ON c.customer_id = cs.customer_id;
SELECT 
    STRFTIME('%Y-%m', order_date) AS month,
    SUM(quantity * b.price) AS total_revenue
FROM Orders o
JOIN Books b ON o.book_id = b.book_id
GROUP BY month
ORDER BY month;
SELECT 
    c.customer_id,
    c.name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING total_orders > 1;
SELECT 
    ROUND(SUM(quantity * b.price) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM Orders o
JOIN Books b ON o.book_id = b.book_id;
SELECT 
    o1.book_id AS book_1,
    o2.book_id AS book_2,
    COUNT(*) AS times_bought_together
FROM Orders o1
JOIN Orders o2 
  ON o1.customer_id = o2.customer_id AND o1.order_id != o2.order_id
WHERE o1.book_id < o2.book_id
GROUP BY book_1, book_2
ORDER BY times_bought_together DESC
LIMIT 10;
SELECT 
    c.customer_id,
    c.name,
    MAX(o.order_date) AS last_purchase,
    ROUND(julianday('2025-07-01') - julianday(MAX(o.order_date))) AS days_since_last_purchase
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING days_since_last_purchase > 365;