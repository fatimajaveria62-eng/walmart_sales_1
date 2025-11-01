SELECT * FROM walmart.cleaned_output;
--
SELECT COUNT(*) FROM walmart.cleaned_output;

SELECT 
COUNT(distinct Branch)
FROM walmart.cleaned_output;

SELECT MAX(quantity) FROM walmart.cleaned_output;
-- BUSINESS Problems
-- find different payment method and nymber of transactions, number of qty sold

SELECT
     payment_method,
     COUNT(*) AS no_payments,
     SUM(quantity) AS no_qty_sold
FROM walmart.cleaned_output
GROUP BY payment_method;

-- Identify the highest rated category in each branch, displaying branch,category ,avg rating

WITH category_avg AS (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rnk
    FROM walmart.cleaned_output
    GROUP BY branch, category
)
SELECT 
    branch,
    category,
    avg_rating,
    rnk
FROM category_avg
ORDER BY branch, rnk;
-- Identify the busiest day for each branch based on the number of transactions


SELECT *
FROM (
    SELECT
        Branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart.cleaned_output
    GROUP BY Branch, DAYNAME(STR_TO_DATE(date, '%d/%m/%y'))
) AS ranked_days
WHERE rnk = 1;

-- Determine the average,minimum,and maximum rating of category for each city,list the city ,average rating,min_rating, and max rating 
SELECT 
    City,
    category,
    AVG(Rating) AS average_rating,
    MIN(Rating) AS min_rating,
    MAX(Rating) AS max_rating
FROM walmart.cleaned_output
GROUP BY City,category;

-- calculate the total profit for each category by  considering total_profit as (unit_price*quantity*profit_margin)
-- list category and total_profit, ordered from highest to lowest.

SELECT 
    Category,

    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart.cleaned_output
GROUP BY Category
ORDER BY total_profit DESC;

-- Determine the most common payment method for each branch.alter
-- Display Branch and the preferred_payment_method.
WITH payment_ranked AS (
    SELECT 
        Branch,
        payment_method,
        COUNT(*) AS method_count,
        RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart.cleaned_output
    GROUP BY Branch, payment_method
)

SELECT 
    *
FROM payment_ranked
WHERE rnk = 1;

-- Categorize sales into 3 groups morning,afternoon evening
-- find out each of of the shift and number of invoices



SELECT 
    Branch,
    shift,
    COUNT(*) AS no_of_invoices
FROM (
    SELECT 
        Branch,
        invoice_id,
        CASE 
            WHEN TIME_FORMAT(time, '%H:%i:%s') BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
            WHEN TIME_FORMAT(time, '%H:%i:%s') BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM walmart.cleaned_output
) AS shift_data
GROUP BY Branch, shift;

-- Identify 5 branch with highest decrease ratio in revenue compared to last year

SELECT 
    Branch,
    prev_year_revenue ,
    curr_year_revenue,
  ROUND((prev_year_revenue - curr_year_revenue) / prev_year_revenue * 100, 2) AS decrease_percentage

FROM (
    SELECT 
        Branch,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022 THEN unit_price * quantity ELSE 0 END) AS prev_year_revenue,
        SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 THEN unit_price * quantity ELSE 0 END) AS curr_year_revenue
    FROM walmart.cleaned_output
    GROUP BY Branch
) AS revenue_diff
WHERE curr_year_revenue < prev_year_revenue
ORDER BY decrease_percentage DESC
LIMIT 5;