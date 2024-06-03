/*
Create a rolling weeks average using Db2.

Explanation:
1. WeekYear CTE:
- Creates a common table expression (CTE) to generate distinct year and week combinations.
- Ensures the week number is between 1 and 52 and the year is 2017 or later.

2. CTE with Sales Data:
- Joins the sales_data table with the WeekYear CTE to ensure each product has entries for each week.
- Computes the sales quantity for each product and week.

3. Compute Cumulative Sum:
- Uses the SUM window function with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW to compute the cumulative sum over time.
- This window frame includes all rows from the start of the partition up to the current row.

4. Select Results:
- Selects the year, week, product ID, and the cumulative sales quantity.
- Orders the results by product ID, year, and week for easy reading.

This query demonstrates how to calculate a cumulative sum using the specified window frame in Db2, adapted to a simplified schema with dummy columns and tables. Adjust the logic and table names as needed to fit your actual schema and data.
*/

-- Step 1: Create a CTE to represent the distinct years and weeks
WITH WeekYear AS (
    SELECT DISTINCT 
        TRIM(YEAR(sales_date)) AS "Year",
        LPAD(TRIM(WEEK(sales_date)), 2, '0') AS "Week"
    FROM sales_data
    WHERE TRIM(WEEK(sales_date)) BETWEEN 1 AND 52
    AND YEAR(sales_date) >= '2017'
),

-- Step 2: Create a CTE to join sales data with the week-year CTE
cte AS (
    SELECT
        wy."Year",
        wy."Week",
        s.product_id AS "Product ID",
        CAST(ROUND(IFNULL(s.sales_qty, 0), 2) AS DECIMAL(18,2)) AS "Sales Quantity"
    FROM sales_data s
    CROSS JOIN WeekYear wy
)

-- Step 3: Compute the cumulative sum directly in the SELECT statement
SELECT
    cte."Year",
    cte."Week",
    cte."Product ID",
    COALESCE(SUM(cte."Sales Quantity") OVER(PARTITION BY cte."Product ID"
        ORDER BY cte."Year" ASC, cte."Week" ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0) AS "Cumulative Sales Quantity"
FROM cte
ORDER BY cte."Product ID", cte."Year", cte."Week";