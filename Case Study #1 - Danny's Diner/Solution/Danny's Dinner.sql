CREATE DATABASE dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);


CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
SELECT * FROM members;
SELECT * FROM menu;
SELECT * FROM sales;

# 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS total_amount FROM menu as m INNER JOIN sales as s WHERE m.product_id = s.product_id GROUP BY s.customer_id;

# 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS no_of_days FROM sales GROUP BY customer_id; 

# 3. What was the first item from the menu purchased by each customer?

SELECT cid, mpn FROM (SELECT cid, mpn , row_number() OVER (PARTITION BY cid ORDER BY sod) AS rn FROM (SELECT s.customer_id as cid, m.product_name as mpn , s.order_date as sod FROM sales as s INNER JOIN menu as m WHERE s.product_id = m.product_id)a)b WHERE b.rn=1 ; 
# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT s.product_id, m.product_name, COUNT(m.product_name) as total_order FROM sales as s INNER JOIN menu as m WHERE s.product_id = m.product_id GROUP BY product_id ORDER BY COUNT(m.product_name) DESC LIMIT 1;

# 5. Which item was the most popular for each customer?

SELECT cid, mpn FROM (SELECT cid, mpn, row_number() OVER (partition by cid ORDER BY pn DESC)as rn FROM (SELECT s.customer_id as cid , m.product_name as mpn, COUNT(product_name) as pn FROM sales as s INNER JOIN menu as m WHERE s.product_id = m.product_id GROUP BY customer_id, product_name)a)b WHERE b.rn=1;

# 6. Which item was purchased first by the customer after they became a member?

SELECT cid, mpn, sod FROM (SELECT cid, mpn, sod, row_number() OVER (partition by cid ORDER BY sod) AS rn FROM(SELECT s.customer_id as cid ,m.product_name as mpn,s.order_date as sod FROM sales as s INNER JOIN members as me ON s.customer_id = me.customer_id INNER JOIN menu as m ON s.product_id = m.product_id WHERE s.order_date > me.join_date)a)b WHERE rn=1;

# 7. Which item was purchased just before the customer became a member?

SELECT cid, mpn, sod FROM (SELECT cid, mpn, sod, row_number() OVER (partition by cid ORDER BY sod DESC) AS rn FROM(SELECT s.customer_id as cid ,m.product_name as mpn,s.order_date as sod FROM sales as s INNER JOIN members as me ON s.customer_id = me.customer_id INNER JOIN menu as m ON s.product_id = m.product_id WHERE s.order_date < me.join_date)a)b WHERE rn=1;

# 8. What is the total items and amount spent for each member before they became a member?

SELECT cid as customer, SUM(mp) as total_price, COUNT(mpn) AS total_item FROM (SELECT s.customer_id as cid ,m.price as mp ,m.product_name as mpn,s.order_date as sod FROM sales as s INNER JOIN members as me ON s.customer_id = me.customer_id INNER JOIN menu as m ON s.product_id = m.product_id WHERE s.order_date < me.join_date)a GROUP BY cid;

# 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer, SUM(CASE WHEN product='sushi' THEN price *10*2 ELSE price*10 END) AS points FROM(SELECT s.customer_id as customer , m.product_name as product,m.price as price FROM sales as s INNER JOIN menu as m ON s.product_id = m.product_id)a GROUP BY customer; 

# 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
  m.customer_id as customer,
  SUM(
    CASE
      WHEN s.order_date BETWEEN m.join_date AND DATE_ADD(m.join_date, INTERVAL 1 WEEK) THEN p.price * 2 * 10 ELSE
	  (CASE WHEN p.product_name = 'sushi' THEN p.price * 10 * 2
      ELSE p.price * 10 END)
    END
  ) AS total_points
FROM
  sales s
JOIN
  menu p ON s.product_id = p.product_id
JOIN
  members m ON s.customer_id = m.customer_id
WHERE
  s.order_date BETWEEN '2021-01-01' AND '2021-01-31' 
GROUP BY
  m.customer_id;

#BONUS QUESTION 1 creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

SELECT s.customer_id, s.order_date, m.product_name, m.price ,(CASE WHEN s.order_date >= me.join_date THEN 'Y' ELSE 'N' END) AS member_ FROM sales as s INNER JOIN menu as m ON s.product_id = m.product_id LEFT JOIN members as me ON me.customer_id = s.customer_id ORDER BY s.customer_id,s.order_date;

#BONUS QUESTION 2 Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

SELECT *, CASE 
WHEN member_ = 'Y' THEN RANK() OVER (ORDER BY sod) ELSE NULL END AS Ranking FROM  
(SELECT s.customer_id, s.order_date as sod , m.product_name, m.price ,(CASE WHEN s.order_date >= me.join_date THEN 'Y' ELSE 'N' END) AS member_ FROM sales as s INNER JOIN menu as m ON s.product_id = m.product_id LEFT JOIN members as me ON me.customer_id = s.customer_id ORDER BY s.customer_id,s.order_date)a;



