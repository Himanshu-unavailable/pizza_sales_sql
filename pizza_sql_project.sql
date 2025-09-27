                                                   -- PROJECT USING DOMINOZ DATA


create database pizzahut;
USE PIZZAHUT;


 -- creating required tables
 

CREATE TABLE pizza (
    pizza_id VARCHAR(30) PRIMARY KEY NOT NULL,
    pizza_type_id VARCHAR(40),
    size VARCHAR(10),
    price FLOAT
);
drop table if exists pizza_types;orders
CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(30) PRIMARY KEY NOT NULL,
    name VARCHAR(30),
    category VARCHAR(30),
    ingredients VARCHAR(300)
);

CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY NOT NULL,
    order_date DATE,
    order_time TIME
);

CREATE TABLE order_details (
    order_details_id VARCHAR(100) PRIMARY KEY NOT NULL,
    order_id VARCHAR(10),
    pizza_id VARCHAR(30),
    quantity INT
);


        -- QUESTIONS
 
 -- Retrieve the total number of orders placed.
 
 SELECT 
    COUNT(ORDER_ID) as total_orders
FROM
    ORDERS;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(price * quantity), 2) AS total_revenue
FROM
    pizza AS p
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id;
    
    
-- Identify the highest-priced pizza.

SELECT 
    price, name
FROM
    pizza_types AS pt
        JOIN
    pizza p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    size, COUNT(order_details_id) AS num
FROM
    pizza p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY size
ORDER BY num DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_type_id, SUM(quantity)
FROM
    order_details od
        JOIN
    pizza p ON p.pizza_id = od.pizza_id
GROUP BY pizza_type_id
ORDER BY SUM(quantity) DESC
LIMIT 5
;



-- Join the necessary tables to find the total quantity of each pizza category ordered


SELECT 
    category, SUM(quantity)
FROM
    order_details od
        JOIN
    pizza p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY category;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time); 



-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(pizza_type_id)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.


SELECT 
    name, SUM(price * quantity) AS revenue
FROM
    pizza p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    p.pizza_type_id,
    SUM(quantity * price) / (SELECT 
            ROUND(SUM(price * quantity), 2)
        FROM
            pizza AS p
                JOIN
            order_details AS od ON od.pizza_id = p.pizza_id) * 100 AS revenue
FROM
    pizza p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY p.pizza_type_id
ORDER BY revenue DESC;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select name , category , revenue , rank() over (partition by category order by revenue desc) as rn from  
(select category , name , sum(quantity*price) as revenue from pizza_types pt
join pizza p on p.pizza_type_id = pt.pizza_type_id 
join order_details od on od.pizza_id = p.pizza_id 
group by category , name 
) as t;