SELECT * FROM WALMART;


SELECT COUNT(*) FROM WALMART;

SELECT DISTINCT payment_method FROM WALMART;

SELECT 
	payment_method,
	count(*) as total_count
FROM WALMART
GROUP BY payment_method;

SELECT 
count (DISTINCT branch)
FROM WALMART;

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold..

SELECT 
	payment_method,
	count(*) as total_count,
	SUM(quantity) as total_quantity
FROM WALMART
GROUP BY payment_method;


-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING...

SELECT * FROM 
(
SELECT 
	BRANCH,
	CATEGORY,
	AVG(RATING) AS avg_rating,
	RANK() OVER (PARTITION BY BRANCH ORDER BY AVG(rating) DESC ) AS RANK
FROM WALMART
GROUP BY 1,2
)
WHERE RANK =1


-- Q.3 Identify the busiest day for each branch based on the number of transactions..

SELECT * FROM 
(
SELECT 
	BRANCH,
	TO_CHAR(TO_DATE(DATE, 'DD/MM/YYYY'),'DAY') AS DAY_NAME,
	count(*) as total_count,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS RANK
FROM WALMART
GROUP BY 1,2)
WHERE RANK = 1


-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT 
	payment_method,
	SUM(quantity) as total_quantity
FROM WALMART
GROUP BY payment_method;


-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	AVG(rating) AS AVG_RATING,
	MIN(rating) AS MIN_RATING,
	MAX(rating) AS MAX_RATING
FROM WALMART
GROUP BY 1,2
ORDER BY 1,2;


-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.


SELECT
	category,
	SUM(total) as total_revenue,
	SUM(total*profit_margin) as total_profit
FROM WALMART
GROUP BY 1


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.


SELECT * FROM 
(SELECT
	payment_method,
	COUNT(*) AS total_count,
	branch,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS RANK
FROM WALMART
GROUP BY 1,3)
WHERE RANK = 1;


-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices.

SELECT 
	branch,
	CASE
		WHEN EXTRACT(HOUR FROM(time::time)) <12 THEN 'MORNING'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
		END day_time,
		COUNT(*)
FROM WALMART
GROUP BY 1,2
ORDER BY 1,3 DESC;


-- 
-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)


SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS FORMATED_DATE
FROM WALMART
LIMIT 10;


WITH REVENUE_2022 AS (
    SELECT
        branch,
        SUM(total) as revenue
    FROM WALMART
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY 1
),
REVENUE_2023 AS (
    SELECT
        branch,
        SUM(total) as revenue
    FROM WALMART
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY 1
)

SELECT 
    LYS.branch,
    LYS.revenue as last_year_revenue,
    CYS.revenue as cr_year_revenue,
    ROUND(
        (LYS.revenue - CYS.revenue)::numeric /
        LYS.revenue::numeric * 100, 
        2) as rev_dec_ratio
FROM REVENUE_2022 AS LYS
JOIN REVENUE_2023 AS CYS
    ON LYS.branch = CYS.branch
WHERE LYS.revenue > CYS.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;