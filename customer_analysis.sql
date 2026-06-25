select * from customer limit 20;

--total revenue collected by male vs female customers --
CREATE VIEW revenue_by_gender AS
SELECT
    gender,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender;

-- Which customers used a discount but still spent more than the average purchase amount--

SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
AND purchase_amount > (
    SELECT AVG(purchase_amount)
    FROM customer
);

--WHich are the top 5 products with the highest average review_rating--
SELECT
    item_purchased,
    AVG(review_rating) AS avg_review_rating
FROM customer
GROUP BY  item_purchased
ORDER BY avg_review_rating DESC
LIMIT 5;

--compare the average purchase amounts between standard and express shipping--
select shipping_type,
       ROUND(AVG(purchase_amount),2) as Average_revenue
from customer
WHERE shipping_type IN ('Standard', 'Express')
group by shipping_type;

--Do subscribed customers spend more? compare average spend and total revenue between subscribers and non-subscribers.

select subscription_status,
       COUNT(customer_id) as total_customers,
       ROUND(AVG(purchase_amount),2) as avg_spend,
       ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status 
order by total_revenue, avg_spend desc;

--which 5 products have the highest percentage of purchases with discounts applied?--
SELECT
    item_purchased,
    COUNT(*) AS total_purchases,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) AS discounted_purchases,
    ROUND((SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)),2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

--Segment customers into new, returning and loyal based on there total number of previous purchases and show the count of each segment--

WITH customer_type AS (
SELECT
customer_id,
previous_purchases,
CASE
WHEN previous_purchases = 1 THEN 'New'
WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
ELSE 'Loyal'
END AS customer_segment
FROM customer
)
SELECT
customer_segment,
COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment;

--what are the top 3 most purchased products within each category--
WITH item_counts AS (
SELECT
category,
item_purchased,
COUNT(customer_id) AS total_orders,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
FROM customer
GROUP BY category, item_purchased
)
SELECT
item_rank,
category,
item_purchased,
total_orders
FROM item_counts
WHERE item_rank <= 3;

SELECT
subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- revenue contribution of each age group--
SELECT sum(purchase_amount) as total_revenue,
       age_group
from customer
group by age_group
order by total_revenue desc