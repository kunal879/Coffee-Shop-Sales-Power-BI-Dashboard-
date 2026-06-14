SELECT * FROM coffee_shop_sales_db.coffee_shop_sales;

SET SQL_SAFE_UPDATES = 0;

update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y')

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

1. Total Sales Analysis;
select round (SUM(unit_price * transaction_qty),1) as Total_Sales 
from coffee_shop_sales
where
month(transaction_date) = 5 -- May Month;

2. TOTAL SALES KPI - MOM DIFFERENCE AND MOM ;

Select
month(transaction_date) as month,
round(sum(unit_price*transaction_qty))AS total_sles,
(sum(unit_price*transaction_qty)-lag(sum(unit_price*transaction_qty),1)
over(order by month(transaction_date)))/ LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

3 Total order Analysis;
select count(transaction_id) AS Total_order
from coffee_shop_sales
where
month(transaction_date) = 5 -- May Month;

4. TOTAL ORDERS KPI - MOM DIFFERENCE AND MOM GROWTH;
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


5. TOTAL QUANTITY SOLD;
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5 -- for month of (CM-May)


6. TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH;
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


7. CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS;
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-05-18'; --For 18 May 2023;
    
    
8. SALES BY WEEKDAY / WEEKEND;
SELECT 
    CASE 
    WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'k') AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END;

9 . SALES BY STORE LOCATION;
SELECT
      store_location,
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2),'K') AS Total_sales
      FROM coffee_shop_sales 
      WHERE MONTH(transaction_date) = 5 -- MAY
      GROUP BY store_location
      ORDER BY SUM(unit_price * transaction_qty) DESC
      

10. Find Average Revenuse and Sales ;
SELECT 
CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Avg_Sales
FROM
(
SELECT SUM(transaction_qty * unit_price) AS total_sales 
FROM coffee_shop_sales
WHERE MONTH (transaction_date) = 5
GROUP BY transaction_date
) AS Internal_query
 
Find daily sales;
SELECT 
DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty),1) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5  -- Filter for May
GROUP BY 
    DAY(transaction_date)
ORDER BY 
    DAY(transaction_date);

Comparing daily sales with Average sales IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”;

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;


11. Sales by product category;
SELECT 
     product_category, 
     SUM(unit_price * transaction_qty) AS total_sales 
     FROM coffee_shop_sales
     WHERE MONTH (transaction_date) = 5
     GROUP BY product_category
     ORDER BY SUM(unit_price * transaction_qty) DESC;

12. Top 10 product by sales 
SELECT 
     product_type, 
     SUM(unit_price * transaction_qty) AS total_sales 
     FROM coffee_shop_sales
     WHERE MONTH (transaction_date) = 5 AND product_category = 'coffee'
     GROUP BY product_type
     ORDER BY SUM(unit_price * transaction_qty) DESC 
     LIMIT 10;
     
13. Sales by days and hours ;
SELECT 
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    coffee_shop_sales
WHERE 
    DAYOFWEEK(transaction_date) = 3 -- Filter for Tuesday (1 is Sunday, 2 is Monday, ..., 7 is Saturday)
    AND HOUR(transaction_time) = 8 -- Filter for hour number 8
    AND MONTH(transaction_date) = 5; -- Filter for May (month number 5);


14. TO GET SALES FOR ALL HOURS FOR MONTH OF MAY; 
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);

15. TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY;
    SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


     




