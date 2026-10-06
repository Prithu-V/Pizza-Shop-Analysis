CREATE DATABASE PIZZA;
use PIZZA;
select * from order_details limit 5;
select * from orders limit 5;
select * from pizzas limit 5;
select * from pizza_types limit 5;

-- Total number of orders placed.
select Count(*) from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum(od.quantity * p.price),2) as total_sales
from order_details od
left join pizzas p on od.pizza_id = p.pizza_id;

-- Revenue Breakdown by Pizza Type
select round(sum(od.quantity * p.price),2) as total_sales,
pt.name as Pizza_Name
from order_details od
left join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by Pizza_Name
order by total_sales desc;
-- Identify the highest-priced pizza.
select name as Pizza,max(price) as Highest_Price
from pizzas p
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by name
limit 1;
-- Identify the most common pizza size ordered.
select size as size,sum(quantity) as ttl_quantity_orderd from order_details od
join pizzas p on od.pizza_id = p.pizza_id
group by size
order by ttl_quantity_orderd desc;

-- List the top 5 most ordered pizza types along with their quantities.
select name as Pizza_Name,sum(quantity) as Total_quantities_ordered from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by Pizza_Name
order by sum(quantity) desc;

-- Intermediate:
-- Total quantity of each pizza category ordered
select sum(quantity) as Total_Quantity,
Category from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by category
order by sum(quantity) desc;

-- Determine the distribution of orders by hour of the day
	-- (at which time the orders are maximum, for inventory management and resource allocation).
SELECT 
    HOUR(o.time) AS hour_of_day,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(od.quantity) AS total_pizzas_sold
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
GROUP BY HOUR(o.time)
ORDER BY hour_of_day ASC;

-- Find the category-wise distribution of pizzas (to understand customer behaviour).
select 
	count(distinct order_details_id) as Orders_Placed,
	category 
    from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by category
order by Orders_Placed desc;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
with daily_orders as(	
    select date, sum(quantity) as ttl_pizzas from orders o
	join order_details od on o.order_id = od.order_id
	group by date
    )
select round(avg(ttl_pizzas),2) as Avg_Pizza_Order
from daily_orders;

-- Determine the top 3 most ordered pizza types based on revenue 
-- (see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)
select name,
	sum(price * quantity) as sales
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by name
order by sales desc
limit 3;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)
with revenue as (
	select 
	name,
	round(sum(price * quantity),2) as revenue
	from pizza_types pt
	join pizzas p on pt.pizza_type_id = p.pizza_type_id
	join order_details od on p.pizza_id = od.pizza_id
	group by name
	order by revenue desc
)
SELECT
    name,
    revenue,
    ROUND(
        revenue * 100 / SUM(revenue) OVER (),
        2
    ) AS contribution_percentage
FROM revenue
ORDER BY revenue DESC;

-- Analyze the cumulative revenue generated over time.
WITH daily_revenue AS (
    SELECT
        o.date,
        SUM(p.price * od.quantity) AS revenue
    FROM orders o
    JOIN order_details od
        ON o.order_id = od.order_id
    JOIN pizzas p
        ON od.pizza_id = p.pizza_id
    GROUP BY o.date
)

SELECT
    date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY date
    ) AS cumulative_revenue
FROM daily_revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category (In each category which pizza is the most selling)
# CTE 1
with pizza_revenue as (
	select 
	sum(price * quantity) as revenue,
	Category as pizza_category,
	name as pizza_name
	from pizza_types pt
	join pizzas p on pt.pizza_type_id = p.pizza_type_id
	join order_details od on p.pizza_id = od.pizza_id
	group by Category,name
),
# CTE 2
pizza_rank as (
	select pizza_category,
    pizza_name,
    revenue,
    rank() over(Partition by pizza_category order by revenue desc) as ranking
    from pizza_revenue
)

select * from pizza_rank 
where ranking <= 3
order by pizza_category, ranking

