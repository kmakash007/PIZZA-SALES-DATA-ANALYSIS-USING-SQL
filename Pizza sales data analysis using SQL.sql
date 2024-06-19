/*Basic:-*/
/* Q1:-Retrieve the total number of orders placed.*/
SELECT COUNT(order_id) AS total_numbers 
FROM orders;

/* Q2:-Calculate the total revenue generated from pizza sales.*/
SELECT SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id

/* Q3:-Identify the highest-priced pizza.*/
SELECT TOP 1 pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC;

/* Q4:-Identify the most common pizza size ordered.*/
SELECT TOP 1 pizzas.size, COUNT(order_details.order_details_id) AS common_order
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY common_order DESC;

/* Q5:-List the top 5 most ordered pizza types along with their quantities.*/
SELECT TOP 5 pizza_types.name, SUM(CONVERT(INT, order_details.quantity)) AS total_quantity 
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC;

/*Intermediate:-*/
/* Q1:-Join the necessary tables to find the total quantity of each pizza category ordered.*/
SELECT pizza_types.category, SUM(CONVERT(INT, order_details.quantity)) AS total_quantity
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

/* Q2:-Determine the distribution of orders by hour of the day.*/
SELECT DATEPART(hour, time) AS order_hour, COUNT(order_id) AS total_order
FROM orders
GROUP BY DATEPART(hour, time)
ORDER BY total_order;

/* Q3:-Find the category-wise distribution of pizzas.*/
SELECT category, COUNT(name) AS total_count
FROM pizza_types
GROUP BY category;

/* Q4:-Group the orders by date and calculate the average number of pizzas ordered per day.*/
SELECT avg(total_quantity) FROM
(SELECT orders.date, SUM(CONVERT(INT, order_details.quantity)) AS total_quantity
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS order_quantity;

/* Q5:-Determine the top 3 most ordered pizza types based on revenue.*/
SELECT TOP 3 pizza_types.name, SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY revenue DESC;

/*Advanced:-*/
/* Q1:-Calculate the percentage contribution of each pizza type to total revenue.*/
SELECT pizza_types.category, 
(SUM(order_details.quantity * pizzas.price) / 
(SELECT SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100 AS revenue

FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

/* Q2:-Analyze the cumulative revenue generated over time.*/
SELECT date, SUM(revenue) OVER(ORDER BY date) AS cumulative
FROM
(SELECT orders.date, SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN orders ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS sales;

/* Q3:-Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/
SELECT TOP 3 name, revenue FROM
(SELECT category, name, revenue, rank() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT pizza_types.category, pizza_types.name, SUM(order_details.quantity * pizzas.price) 
AS revenue
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3;