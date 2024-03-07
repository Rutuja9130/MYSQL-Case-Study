CREATE DATABASE pizza_runner;
USE pizza_runner;

CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');



CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');



CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');



CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');



CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);

INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

SELECT * FROM customer_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
SELECT * FROM runner_orders;


SELECT * FROM runners;

# A. Pizza Metrics
# 1. How many pizzas were ordered?
SELECT COUNT(*) as Total_orders FROM customer_orders;

# 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) as unique_order FROM customer_orders;

# 3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*) AS Successful_orders FROM runner_orders WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation') GROUP BY runner_id;

# 4. How many of each type of pizza was delivered?
SELECT pizza_id ,COUNT(pizza_id) as total_pizza FROM customer_orders as c INNER JOIN (SELECT * FROM runner_orders WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))a ON c.order_id=a.order_id GROUP BY c.pizza_id;

# 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT c.customer_id, p.pizza_name, count(c.pizza_id) as total FROM customer_orders as c INNER JOIN pizza_names as p ON c.pizza_id = p.pizza_id GROUP BY c.customer_id,p.pizza_id ORDER BY c.customer_id;

# 6. What was the maximum number of pizzas delivered in a single order?
SELECT c.order_id, count(c.order_id) as total_order FROM customer_orders as c INNER JOIN (SELECT * FROM runner_orders WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))a ON c.order_id = a.order_id GROUP BY c.order_id ORDER BY COUNT(c.order_id) DESC LIMIT 1;

# 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
# NOT CHANGE
SELECT a.customer_id, COUNT(a.order_time) as total FROM (SELECT 
  *,
  CASE 
    WHEN (exclusions IS NULL OR exclusions = '' OR exclusions = 'null') 
         AND (extras IS NULL OR extras = '' OR extras = 'null') 
    THEN 'Not Change' 
    ELSE 'Change' 
  END AS final_status 
FROM customer_orders)a INNER JOIN (SELECT * FROM runner_orders WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))b ON a.order_id = b.order_id WHERE a.final_status ='Not Change' GROUP BY a.customer_id;


# At least one change
SELECT a.customer_id, COUNT(a.order_time) as total FROM (SELECT 
  *,
  CASE 
    WHEN (exclusions IS NOT NULL OR exclusions != '' OR exclusions != 'null') 
         OR (extras IS NOT NULL OR extras != '' OR extras != 'null') 
    THEN 'Change' 
    ELSE 'Not Change' 
  END AS final_status 
FROM customer_orders)a INNER JOIN (SELECT * FROM runner_orders WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))b ON a.order_id = b.order_id WHERE a.final_status ='change' GROUP BY a.customer_id;


#How many pizzas were delivered that had both exclusions and extras?
SELECT a.customer_id, COUNT(a.order_time) as total FROM (SELECT 
  *,
  CASE 
    WHEN (exclusions IS NOT NULL AND exclusions != '' AND exclusions != 'null') 
         AND (extras IS NOT NULL AND extras != '' AND extras != 'null') 
    THEN 'Change' 
    ELSE 'Not Change' 
  END AS final_status 
FROM customer_orders)a INNER JOIN (SELECT * FROM runner_orders WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))b ON a.order_id = b.order_id WHERE a.final_status ='Change' GROUP BY a.customer_id;


# 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
CONCAT(DATE_FORMAT(order_time,'%l'),'-',(DATE_FORMAT(DATE_ADD(order_time, INTERVAL 1 HOUR),'%l' '%p'))) AS hour_bin,
COUNT(*) AS total_orders
FROM
customer_orders
GROUP BY hour_bin
ORDER BY
hour_bin;

# 10. What was the volume of orders for each day of the week?
SELECT DAYNAME(order_time) as day_of_week,
COUNT(order_id) as total_order
FROM customer_orders
GROUP BY day_of_week
ORDER BY dayofweek(order_time);


# B. Runner and Customer Experience
# 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)SELECT DISTINCT WEEK(signup_date, 1) AS week_number
SELECT
  w.week_number,
  COUNT(r.runner_id) AS runners_signed_up
FROM (
  SELECT DISTINCT WEEK(pickup_time, 1) AS week_number
  FROM runner_orders
  WHERE pickup_time >= '2021-01-01'
) w
LEFT JOIN runner_orders r ON WEEK(r.pickup_time, 1) = w.week_number
GROUP BY
  w.week_number
ORDER BY
  w.week_number;


# 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT rid as runner_id, AVG(time_required) as avg_time FROM (SELECT ro.runner_id as rid ,c.order_id as cid , timestampdiff(minute,c.order_time,ro.pickup_time) as time_required FROM customer_orders as c INNER JOIN runner_orders as ro ON c.order_id = ro.order_id)a GROUP BY a.rid;

# 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
SELECT distinct(a.cid) as order_id, b.total_pizza,a.time_required FROM (SELECT c.order_id as cid , timestampdiff(minute,c.order_time,ro.pickup_time) as time_required FROM customer_orders as c INNER JOIN runner_orders as ro ON c.order_id = ro.order_id)a 
INNER JOIN
(SELECT order_id, COUNT(pizza_id) as total_pizza FROM customer_orders GROUP BY order_id)b ON a.cid = b.order_id WHERE a.time_required IS NOT NULL;

 # 4. What was the average distance travelled for each customer?

SELECT c.customer_id,AVG(dist) as average_distance FROM customer_orders as c INNER JOIN (SELECT a.order_id as order_,a.distance as dist FROM (SELECT order_id, CASE WHEN distance like "%km" THEN CAST(SUBSTRING(distance,1,LENGTH(distance)-2) AS SIGNED) 
WHEN distance like "% km" THEN CAST(SUBSTRING(distance,1,LENGTH(distance)-3) AS SIGNED)
ELSE CAST(distance AS signed) END as distance FROM runner_orders)a WHERE a.distance !=0)b ON c.order_id = b.order_ GROUP BY c.customer_id;

# 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(a.duration)-MIN(a.duration) as interval_of_time FROM  (SELECT CASE WHEN duration like "%min%" THEN CAST(substring(duration,1,2) AS SIGNED) ELSE CAST(duration as SIGNED) END as duration
FROM runner_orders WHERE duration != 'null')a;

# 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,order_id ,AVG((distance_ / duration_ ) )as SPEED FROM(SELECT * ,CASE WHEN duration like "%min%" THEN CAST(substring(duration,1,2) AS SIGNED) ELSE CAST(duration as SIGNED) END as duration_,
CASE WHEN distance like "%km" THEN CAST(SUBSTRING(distance,1,LENGTH(distance)-2) AS SIGNED)
WHEN distance like "% km" THEN CAST(SUBSTRING(distance,1,LENGTH(distance)-3) AS SIGNED)
ELSE CAST(distance AS signed) END as distance_ FROM runner_orders WHERE duration != 0 and distance!=0)a GROUP BY runner_id,order_id;

# 7. What is the successful delivery percentage for each runner?

SELECT a.runner_id, ((COUNT(*)/total_order)*100) AS PERC FROM runner_orders as ro INNER JOIN 
(SELECT runner_id, COUNT(*) as total_order FROM runner_orders GROUP BY runner_id)a ON ro.runner_id=a.runner_id WHERE ro.cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation') GROUP BY ro.runner_id;

# D. Pricing and Ratings
# 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT a.pizza, SUM(PRICE) as total_income FROM  (SELECT c.order_id as order_, c.pizza_id as pizza , CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END AS PRICE FROM customer_orders as c INNER JOIN runner_orders as ro ON c.order_id = ro.order_id WHERE cancellation IS NULL or cancellation NOT IN('Restaurant Cancellation','Customer Cancellation'))a GROUP BY a.pizza;

# 2. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

CREATE TABLE RATING(
Score INT,
category VARCHAR(20));

INSERT INTO RATING VALUES (1,'Poor'),(2,'Fair'),(3,'Good'),(4,'Very Good'),(5,'Excellent');

SELECT * FROM RATING;

# If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
SELECT h.order_ , (h.total_amount-h.spend) as earning FROM(SELECT x.order_ as order_, x.dist*0.30 as spend, y.total_amount FROM(
SELECT a.order_id as order_,a.distance as dist FROM (SELECT order_id, CASE WHEN distance like "%km" THEN CAST(SUBSTRING(distance,1,LENGTH(distance)-2) AS SIGNED) 
WHEN distance like "% km" THEN CAST(SUBSTRING(distance,1,LENGTH(distance)-3) AS SIGNED)
ELSE CAST(distance AS signed) END as distance FROM runner_orders)a WHERE a.distance !=0)x INNER JOIN (

SELECT a.order_ as final_order , SUM(PRICE) as total_amount FROM (SELECT c.order_id as order_, c.pizza_id as pizza , CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END AS PRICE FROM customer_orders as c INNER JOIN runner_orders as ro ON c.order_id = ro.order_id WHERE cancellation IS NULL or cancellation NOT IN('Restaurant Cancellation','Customer Cancellation'))a GROUP BY a.order_) y ON x.order_ = y.final_order)h;




