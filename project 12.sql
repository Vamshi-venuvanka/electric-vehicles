USE vehcile;

SELECT COUNT(*) FROM electric_vehicle_sales_by_state;
SELECT COUNT(*) FROM electric_vehicle_sales_by_makers;
SELECT COUNT(*) FROM dim_date;

 ALTER TABLE electric_vehicle_sales_by_state
 RENAME TO sales_by_state;
 
 ALTER TABLE electric_vehicle_sales_by_makers
 RENAME TO sales_by_makers;


 ALTER TABLE sales_by_makers
 RENAME COLUMN ï»¿date TO  date;
 
 ALTER TABLE sales_by_state
 RENAME COLUMN ï»¿date TO  date;

ALTER TABLE dim_date
 RENAME COLUMN ï»¿date TO  date;
 
 select * FROM dim_date;
SELECT * FROM sales_by_makers;
SELECT * FROM dim_date;
 
SET SQL_SAFE_UPDATES=0;
UPDATE dim_date
SET date=
    CASE WHEN LEFT(date,1)=0 THEN SUBSTRING(date,2,LENGTH(date)) ELSE date
END 
WHERE LEFT(date,1)=0;

UPDATE sales_by_state
SET date=
    CASE WHEN LEFT(date,1)=0 THEN SUBSTRING(date,2,LENGTH(date)) ELSE date
END 
WHERE LEFT(date,1)=0;

SELECT * FROM sales_by_state;

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_by_state
SET state = 'Andaman & Nicobar Island'
WHERE state = 'Andaman & Nicobar';

SET SQL_SAFE_UPDATES = 1;


-- 1. List the top 3 and bottom 3 makers for the fiscal years 2023 and 2024 in terms of the number of 2-wheelers sold.
WITH makers_2023 AS (
    SELECT 
        sales_by_makers.maker, -- Select the maker
        dim_date.fiscal_year, -- Select the fiscal year
        SUM(sales_by_makers.electric_vehicles_sold) AS 2_wheelers_Sold, -- Calculate the total number of 2-wheelers sold by each maker
        ROW_NUMBER() OVER(ORDER BY SUM(sales_by_makers.electric_vehicles_sold) DESC) AS rank_desc, -- Rank the makers based on descending order of sales
        ROW_NUMBER() OVER(ORDER BY SUM(sales_by_makers.electric_vehicles_sold) ASC) AS rank_asc -- Rank the makers based on ascending order of sales
    FROM 
        sales_by_makers -- Source table containing sales data by makers
    JOIN
        dim_date -- Join with the date dimension table
    ON 
        dim_date.date = sales_by_makers.date -- Join condition based on the date field
    WHERE 
        dim_date.fiscal_year = 2023 -- Filter for the fiscal year 2023
        AND sales_by_makers.vehicle_category = '2-Wheelers' -- Filter for 2-wheelers category
    GROUP BY 
        sales_by_makers.maker, dim_date.fiscal_year -- Group by maker and fiscal year
    ORDER BY 
        2_wheelers_Sold DESC -- Order results by total 2-wheelers sold in descending order
)

-- Select the top 3 and bottom 3 makers based on the number of 2-wheelers sold
SELECT 
    maker, -- Select the maker
    2_wheelers_Sold -- Select the total number of 2-wheelers sold
FROM 
    makers_2023 -- Referencing the CTE
WHERE 
    rank_desc <= 3 -- Filter for the top 3 makers by sales
    OR rank_asc <= 3 -- Filter for the bottom 3 makers by sales
ORDER BY 
    2_wheelers_Sold; -- Order the final output by the number of 2-wheelers sold



-- top 3 and bottom 3 makers for fiscal year 2024
WITH makers_2024 AS (
    SELECT 
        sales_by_makers.maker, -- Select the maker
        dim_date.fiscal_year, -- Select the fiscal year
        SUM(sales_by_makers.electric_vehicles_sold) AS 2_wheelers_Sold, -- Calculate the total number of 2-wheelers sold by each maker
        ROW_NUMBER() OVER(ORDER BY SUM(sales_by_makers.electric_vehicles_sold) DESC) AS rank_desc, -- Rank the makers based on descending order of sales
        ROW_NUMBER() OVER(ORDER BY SUM(sales_by_makers.electric_vehicles_sold) ASC) AS rank_asc -- Rank the makers based on ascending order of sales
    FROM 
        sales_by_makers -- Source table containing sales data by makers
    JOIN
        dim_date -- Join with the date dimension table
    ON 
        dim_date.date = sales_by_makers.date -- Join condition based on the date field
    WHERE 
        dim_date.fiscal_year = 2024 -- Filter for the fiscal year 2024
        AND sales_by_makers.vehicle_category = '2-Wheelers' -- Filter for 2-wheelers category
    GROUP BY 
        sales_by_makers.maker, dim_date.fiscal_year -- Group by maker and fiscal year
    ORDER BY 
        2_wheelers_Sold DESC -- Order results by total 2-wheelers sold in descending order
)

-- Select the top 3 and bottom 3 makers based on the number of 2-wheelers sold
SELECT 
    maker, -- Select the maker
    2_wheelers_Sold -- Select the total number of 2-wheelers sold
FROM 
    makers_2024 -- Referencing the CTE
WHERE 
    rank_desc <= 3 -- Filter for the top 3 makers by sales
    OR rank_asc <= 3 -- Filter for the bottom 3 makers by sales
ORDER BY 
    2_wheelers_Sold; -- Order the final output by the number of 2-wheelers sold

     
-- 2 Identify the top 5 states with the highest penetration rate in 2-wheeler and 4-wheeler EV sales in FY 2024.
SELECT * FROM sales_by_state;

 -- Select the top 5 states based on the penetration rate of 2-wheelers in fiscal year 2024
SELECT 
    sales_by_state.state, -- Select the state
    ROUND((SUM(sales_by_state.electric_vehicles_sold) / SUM(total_vehicles_sold)) * 100, 2) AS penetration_rate -- Calculate and round the penetration rate to 2 decimal places
FROM 
    sales_by_state -- Source table containing sales data by state
LEFT JOIN 
    dim_date -- Join with the date dimension table
ON
    sales_by_state.date = dim_date.date -- Join condition based on the date field
WHERE 
    sales_by_state.vehicle_category = '2-Wheelers' -- Filter for 2-wheelers category
    AND dim_date.fiscal_year = 2024 -- Filter for the fiscal year 2024
GROUP BY 
    sales_by_state.state -- Group by state to calculate the penetration rate for each state
ORDER BY
    penetration_rate DESC -- Order the results by penetration rate in descending order
LIMIT 5; -- Limit the results to the top 5 states

-- top 5  states for 4-wheelers
-- Select the top 5 states based on the penetration rate of 4-wheelers in fiscal year 2024
SELECT 
    sales_by_state.state, -- Select the state
    ROUND((SUM(sales_by_state.electric_vehicles_sold) / SUM(total_vehicles_sold)) * 100, 2) AS penetration_rate -- Calculate and round the penetration rate to 2 decimal places
FROM 
    sales_by_state -- Source table containing sales data by state
LEFT JOIN 
    dim_date -- Join with the date dimension table
ON
    sales_by_state.date = dim_date.date -- Join condition based on the date field
WHERE 
    sales_by_state.vehicle_category = '4-Wheelers' -- Filter for 4-wheelers category
    AND dim_date.fiscal_year = 2024 -- Filter for the fiscal year 2024
GROUP BY 
    sales_by_state.state -- Group by state to calculate the penetration rate for each state
ORDER BY
    penetration_rate DESC -- Order the results by penetration rate in descending order
LIMIT 5; -- Limit the results to the top 5 states



-- 3 List the states with negative penetration (decline) in EV sales from 2022 to 2024?


-- CTE to calculate the penetration rate of electric vehicles for each state across fiscal years 2022 to 2024
WITH neg_rate AS (
    SELECT 
        sales_by_state.state, -- Select the state
        dim_date.fiscal_year, -- Select the fiscal year
        ROUND((SUM(sales_by_state.electric_vehicles_sold) / SUM(total_vehicles_sold)) * 100, 2) AS penetration_rate -- Calculate and round the penetration rate to 2 decimal places
    FROM 
        sales_by_state -- Source table containing sales data by state
    INNER JOIN 
        dim_date -- Join with the date dimension table
    ON
        sales_by_state.date = dim_date.date -- Join condition based on the date field
    WHERE 
        dim_date.fiscal_year BETWEEN 2022 AND 2024 -- Filter data for fiscal years between 2022 and 2024
    GROUP BY 
        sales_by_state.state, dim_date.fiscal_year -- Group by state and fiscal year
    ORDER BY
        penetration_rate ASC -- Order by penetration rate in ascending order (for the CTE)
)

-- Final query to find states where the penetration rate has declined from 2022 to 2024
SELECT 
    pr_2022.state AS state, -- Select the state
    pr_2022.penetration_rate AS penetration_rate_2022, -- Penetration rate in 2022
    pr_2024.penetration_rate AS penetration_rate_2024, -- Penetration rate in 2024
    pr_2024.penetration_rate - pr_2022.penetration_rate AS penetration_decline -- Calculate the decline in penetration rate
FROM 
    neg_rate AS pr_2022 -- Alias for the 2022 penetration rates
JOIN
    neg_rate AS pr_2024 -- Alias for the 2024 penetration rates
ON 
    pr_2022.state = pr_2024.state -- Join based on state
    
WHERE
    pr_2024.penetration_rate < pr_2022.penetration_rate -- Filter for states where penetration rate declined from 2022 to 2024
ORDER BY 
    penetration_decline ASC; -- Order the results by the amount of decline in penetration rate in ascending order
  
  
  -- 5.What are the quarterly trends based on sales volume for the top 5 EV makers (4-wheelers) from 2022 to 2024?
  
  
-- Step 1: Create a CTE (Common Table Expression) named 'filter_data'
WITH filter_data AS (
    SELECT 
        dim_date.quarter,                 -- Select the quarter from the dim_date table
        dim_date.fiscal_year,             -- Select the fiscal year from the dim_date table
        sales_by_makers.electric_vehicles_sold, -- Select the number of electric vehicles sold from the sales_by_makers table
        sales_by_makers.maker             -- Select the maker of the vehicles from the sales_by_makers table
    FROM 
        sales_by_makers
    JOIN 
        dim_date
    ON 
        sales_by_makers.date = dim_date.date  -- Join the sales_by_makers and dim_date tables on the date field
    WHERE 
        sales_by_makers.vehicle_category = "4-Wheelers" AND -- Filter for only 4-Wheeler vehicles
        dim_date.fiscal_year BETWEEN 2022 AND 2024) -- Filter for fiscal years between 2022 and 2024
-- Step 2: Create a CTE named 'total_sales' to aggregate total sales for each maker
, total_sales AS (
    SELECT 
        maker,                            -- Select the maker of the vehicles
        SUM(electric_vehicles_sold) AS total_sales  -- Calculate the total number of electric vehicles sold by summing up the sales
    FROM 
        filter_data                       -- Use the 'filter_data' CTE created in Step 1
    GROUP BY
        maker                           -- Group by maker to get total sales for each maker
    ORDER BY 
        maker DESC                      -- Order the results by maker in descending order
    LIMIT 5                           -- Limit the results to the top 5 makers
)
-- Step 3: Query to get the sales data for the top 5 makers per quarter and fiscal year
SELECT 
    filter_data.quarter,                -- Select the quarter from the 'filter_data' CTE
    filter_data.maker,                  -- Select the maker from the 'filter_data' CTE
    filter_data.fiscal_year,            -- Select the fiscal year from the 'filter_data' CTE
    SUM(filter_data.electric_vehicles_sold) AS top_sales  -- Sum the electric vehicles sold for each combination of quarter, maker, and fiscal year
FROM 
    filter_data                        -- Use the 'filter_data' CTE
JOIN
    total_sales                        -- Join with the 'total_sales' CTE to get only the top 5 makers
ON 
    filter_data.maker = total_sales.maker  -- Join condition to match the maker with the top 5 makers
GROUP BY 
    filter_data.quarter,               -- Group by quarter
    filter_data.maker,                 -- Group by maker
    filter_data.fiscal_year            -- Group by fiscal year
ORDER BY 
    filter_data.quarter,               -- Order the results by quarter
    filter_data.maker,                 -- Order the results by maker
    filter_data.fiscal_year;           -- Order the results by fiscal year

-- 5.How do the EV sales and penetration rates in Delhi compare to Karnataka for 2024?
  

SELECT 
    sales_by_state.state,                                        -- Select the state from the sales_by_state table
    sales_by_state.vehicle_category,                             -- Select the vehicle category (2-Wheelers or 4-Wheelers)
    SUM(sales_by_state.total_vehicles_sold) AS total_vehicle_sold,   -- Calculate the total number of vehicles sold (both electric and non-electric)
    SUM(sales_by_state.electric_vehicles_sold) AS ev_sales,     -- Calculate the total number of electric vehicles sold
    ROUND(SUM(sales_by_state.electric_vehicles_sold) / SUM(sales_by_state.total_vehicles_sold), 2) * 100 AS penetration_rate  -- Calculate the penetration rate of electric vehicles and format it as a percentage
FROM 
    sales_by_state
JOIN 
    dim_date
ON 
    sales_by_state.date = dim_date.date                          -- Join sales_by_state with dim_date on the date field
WHERE
    sales_by_state.state IN ("Delhi", "Karnataka")               -- Filter for data from Delhi and Karnataka
    AND sales_by_state.vehicle_category IN ("2-Wheelers", "4-Wheelers")  -- Filter for 2-Wheelers and 4-Wheelers
    AND dim_date.fiscal_year = 2024                             -- Filter for the fiscal year 2024
GROUP BY  
    sales_by_state.state,                                       -- Group by state to aggregate sales data by state
    sales_by_state.vehicle_category;                            -- Group by vehicle category to differentiate between 2-Wheelers and 4-Wheelers



-- 6 List down the compounded annual growth rate (CAGR) in 4-wheeler units for the top 5 makers from 2022 to 2024.

-- Step 1: Create a CTE named 'CAGR' to calculate the beginning and end values of electric vehicles sold for each maker
WITH CAGR AS (
    SELECT 
        sales_by_makers.maker,  -- Select the maker of the vehicles
        SUM(CASE WHEN dim_date.fiscal_year = 2022 THEN electric_vehicles_Sold ELSE 0 END) AS beginning_value,  -- Calculate the total number of electric vehicles sold in 2022 as the beginning value
        SUM(CASE WHEN dim_date.fiscal_year = 2024 THEN electric_vehicles_Sold ELSE 0 END) AS end_value,  -- Calculate the total number of electric vehicles sold in 2024 as the end value
        MAX(dim_date.fiscal_year) - MIN(dim_date.fiscal_year) AS no_of_periods  -- Calculate the number of periods (years) between 2022 and 2024
    FROM 
        sales_by_makers
    LEFT JOIN 
        dim_date
    ON 
        sales_by_makers.date = dim_date.date  -- Join sales_by_makers with dim_date on the date field
    WHERE 
        sales_by_makers.vehicle_category = "4-Wheelers"  -- Filter for 4-Wheelers only
        AND dim_date.fiscal_year BETWEEN 2022 AND 2024  -- Filter for fiscal years between 2022 and 2024
    GROUP BY 
        sales_by_makers.maker  -- Group by maker to calculate the metrics for each vehicle maker
)

-- Step 2: Calculate the Compound Annual Growth Rate (CAGR) for each maker based on the beginning and end values
SELECT
    maker,  -- Select the maker
    ROUND((POWER(end_value / beginning_value, 1 / no_of_periods) - 1) * 100, 2) AS CAGR  -- Calculate the CAGR using the formula: ((end_value / beginning_value)^(1 / no_of_periods) - 1) * 100, and round to 2 decimal places
FROM 
    CAGR  -- Use the 'CAGR' CTE from Step 1
ORDER BY 
    CAGR DESC  -- Order the results by CAGR in descending order to list the top makers with the highest CAGR
LIMIT 5;  -- Limit the results to the top 5 makers


-- 7.List down the top 10 states that had the highest compounded annual growth rate (CAGR) from 2022 to 2024 in total vehicles sold.

-- Step 1: Create a CTE named 'top_cagr' to calculate the beginning and end values of total vehicles sold for each state
WITH top_cagr AS (
    SELECT 
        sales_by_state.state,  -- Select the state
        SUM(CASE WHEN dim_date.fiscal_year = 2022 THEN sales_by_state.total_vehicles_sold END) AS beginning_value,  -- Calculate the total vehicles sold in 2022 as the beginning value
        SUM(CASE WHEN dim_date.fiscal_year = 2024 THEN sales_by_state.total_vehicles_sold END) AS end_value,  -- Calculate the total vehicles sold in 2024 as the end value
        MAX(dim_date.fiscal_year) - MIN(dim_date.fiscal_year) AS total_years  -- Calculate the number of years between 2022 and 2024
    FROM
        sales_by_state
    LEFT JOIN
        dim_date
    ON 
        sales_by_state.date = dim_date.date  -- Join sales_by_state with dim_date on the date field
    WHERE  
        dim_date.fiscal_year BETWEEN 2022 AND 2024  -- Filter for fiscal years between 2022 and 2024
    GROUP BY 
        sales_by_state.state  -- Group by state to calculate the metrics for each state
)
-- Step 2: Calculate the Compound Annual Growth Rate (CAGR) for each state based on the beginning and end values
SELECT
    state,  -- Select the state
    ROUND((POWER(end_value / beginning_value, 1 / total_years) - 1) * 100, 2) AS CAGR  -- Calculate the CAGR using the formula: ((end_value / beginning_value)^(1 / total_years) - 1) * 100, and round to 2 decimal places
FROM
    top_cagr  -- Use the 'top_cagr' CTE from Step 1
ORDER BY
    CAGR DESC  -- Order the results by CAGR in descending order to list the states with the highest CAGR
LIMIT 10;  -- Limit the results to the top 10 states


-- 8.What are the peak and low season months for EV sales based on the data from 2022 to 2024?
SELECT * FROM sales_by_state;
SELECT * FROM dim_date;
SELECT * FROM sales_by_makers;

-- Step 1: Create a CTE to calculate total electric vehicles sold per month and year
WITH CTE AS (
    SELECT 
        YEAR(STR_TO_DATE(dim_date.date, '%d-%b-%y')) AS year,  -- Extract the year from the date
        DATE_FORMAT(STR_TO_DATE(dim_date.date, '%d-%b-%y'), '%M') AS month_name,  -- Extract the month name from the date
        SUM(sales_by_makers.electric_vehicles_sold) AS total_ev_vehicles_sold  -- Calculate the total number of electric vehicles sold in that month
    FROM 
        sales_by_makers
    JOIN
        dim_date
    ON 
        sales_by_makers.date = dim_date.date  -- Join sales_by_makers with dim_date on the date field
    WHERE 
        YEAR(STR_TO_DATE(dim_date.date, '%d-%b-%y')) BETWEEN 2022 AND 2024  -- Filter for years between 2022 and 2024
    GROUP BY 
        YEAR(STR_TO_DATE(dim_date.date, '%d-%b-%y')),  -- Group by year
        DATE_FORMAT(STR_TO_DATE(dim_date.date, '%d-%b-%y'), '%M')  -- Group by month name
),

-- Step 2: Create another CTE to calculate ranks of total sales for each month within each year
monthly_sales AS (
    SELECT 
        year,  -- Select the year
        month_name,  -- Select the month name
        total_ev_vehicles_sold,  -- Select the total number of electric vehicles sold in that month
        RANK() OVER (PARTITION BY year ORDER BY total_ev_vehicles_sold DESC) AS rank_desc,  -- Rank months by total EV sales in descending order
        RANK() OVER (PARTITION BY year ORDER BY total_ev_vehicles_sold ASC) AS rank_asc  -- Rank months by total EV sales in ascending order
    FROM 
        CTE  -- Use the CTE from Step 1
)

-- Step 3: Select and label the months with the highest and lowest sales for each year
SELECT 
    year,  -- Select the year
    month_name,  -- Select the month name
    total_ev_vehicles_sold,  -- Select the total number of electric vehicles sold in that month
    CASE
        WHEN rank_desc = 1 THEN "peak sales"  -- Label the month with the highest sales as "peak sales"
        WHEN rank_asc = 1 THEN "low sales"  -- Label the month with the lowest sales as "low sales"
    END AS season_months  -- Create a new column for the sales season label
FROM 
    monthly_sales  -- Use the 'monthly_sales' CTE from Step 2
WHERE 
    rank_asc = 1 OR rank_desc = 1  -- Filter for months with either the highest or lowest sales
ORDER BY 
    year ASC,  -- Order the results by year in ascending order
    season_months DESC;  -- Order by season_months in descending order to show "peak sales" before "low sales"

      
-- 9.What is the projected number of EV sales (including 2-wheelers and 4-wheelers) 
-- for the top 10 states by penetration rate in 2030, based on the compounded annual growth rate (CAGR) from previous years?


-- Step 1: Create a CTE to calculate the total electric vehicles sold, total vehicles sold, and penetration rate by state
WITH CTE AS (
    SELECT 
        state,  -- Select the state
        SUM(electric_vehicles_sold) AS total_ev_sold,  -- Calculate the total number of electric vehicles sold in that state
        SUM(total_vehicles_sold) AS total_vehicles_sold,  -- Calculate the total number of vehicles sold in that state
        ROUND(SUM(electric_vehicles_sold) / SUM(total_vehicles_sold), 2) * 100 AS penetration_rate  -- Calculate the EV penetration rate in that state
    FROM 
        sales_by_state
    GROUP BY 
        state  -- Group by state
),

-- Step 2: Create a CTE to rank states by penetration rate and select the top 10
top_10 AS (
    SELECT  
        state,  -- Select the state
        penetration_rate,  -- Select the penetration rate
        ROW_NUMBER() OVER (ORDER BY penetration_rate DESC) AS cnt  -- Rank states by penetration rate in descending order
    FROM
        CTE  -- Use the CTE from Step 1
),

-- Step 3: Create a CTE to select the top 10 states with the highest penetration rates
CAGR AS (
    SELECT 
        state,  -- Select the state
        penetration_rate  -- Select the penetration rate
    FROM
        top_10  -- Use the 'top_10' CTE from Step 2
    WHERE 
        cnt <= 10  -- Filter for the top 10 states
),

-- Step 4: Calculate the Compound Annual Growth Rate (CAGR) for the top 10 states
projected_sales AS (
    SELECT 
        sales_by_state.state,  -- Select the state
        SUM(sales_by_state.electric_vehicles_sold) AS total_ev_sold,  -- Calculate the total electric vehicles sold in that state
        SUM(CASE WHEN dim_date.fiscal_year = 2022 THEN sales_by_state.electric_vehicles_sold END) AS beginning_value,  -- Calculate the total EVs sold in 2022 as the beginning value
        SUM(CASE WHEN dim_date.fiscal_year = 2024 THEN sales_by_state.electric_vehicles_sold END) AS end_value,  -- Calculate the total EVs sold in 2024 as the end value
        MAX(dim_date.fiscal_year) - MIN(dim_date.fiscal_year) AS total_years,  -- Calculate the number of years between 2022 and 2024
        ROUND((POWER(SUM(CASE WHEN dim_date.fiscal_year = 2024 THEN sales_by_state.electric_vehicles_sold ELSE 0 END) / SUM(CASE WHEN dim_date.fiscal_year = 2022 THEN sales_by_state.electric_vehicles_sold ELSE 0 END), 1 / 2) - 1), 2) AS cagr  -- Calculate the CAGR for each state over the period
    FROM
        sales_by_state
    LEFT JOIN 
        dim_date
    ON 
        sales_by_state.date = dim_date.date  -- Join sales_by_state with dim_date on the date field
    WHERE
        sales_by_state.state IN (SELECT state FROM CAGR)  -- Filter for states in the top 10 list
    GROUP BY
        sales_by_state.state  -- Group by state
),

-- Step 5: Project sales for 2030 based on CAGR
joining AS (
    SELECT 
        state,  -- Select the state
        ROUND(total_ev_sold * POWER(1 + cagr, 2030 - 2024), 2) AS projected_sales_2030  -- Project the total EV sales for 2030 using the CAGR formula
    FROM
        projected_sales  -- Use the 'projected_sales' CTE from Step 4
)

-- Step 6: Join the CAGR data with the projected sales data and order the results
SELECT  
    CAGR.state,  -- Select the state
    CAGR.penetration_rate,  -- Select the penetration rate
    joining.projected_sales_2030  -- Select the projected sales for 2030
FROM
    CAGR
JOIN 
    joining
ON
    CAGR.state = joining.state  -- Join the 'CAGR' and 'joining' CTEs on the state field
ORDER BY 
    joining.projected_sales_2030 DESC;  -- Order the results by projected sales for 2030 in descending order
    
    

-- 10 Estimate the revenue growth rate of 4-wheeler and 2-wheelers EVs in India for 2022 vs 2024 and 2023 vs 2024, assuming an average unit price. H
  -- Join the two tables to get date-related information

   
   -- Step 1: Join the sales_by_state data with the dim_date table and aggregate by fiscal year, state, and vehicle category
WITH joined_data AS (
    SELECT 
        dim_date.fiscal_year,  -- Select the fiscal year
        sales_by_state.state,  -- Select the state
        sales_by_state.vehicle_category,  -- Select the vehicle category (2-Wheelers or 4-Wheelers)
        SUM(sales_by_state.electric_vehicles_sold) AS electric_vehicles_sold,  -- Calculate the total number of electric vehicles sold in that state and category
        SUM(sales_by_state.total_vehicles_sold) AS total_vehicles_sold  -- Calculate the total number of vehicles sold in that state and category
    FROM 
        sales_by_state 
    JOIN 
        dim_date  
    ON 
        sales_by_state.date = dim_date.date  -- Join the sales data with the date dimension table on the date field
    GROUP BY  
        dim_date.fiscal_year,  -- Group by fiscal year
        sales_by_state.state,  -- Group by state
        sales_by_state.vehicle_category  -- Group by vehicle category
),

-- Step 2: Calculate revenue for each vehicle category, fiscal year, and state based on the number of electric vehicles sold
revenue_data AS (
    SELECT 
        state,  -- Select the state
        fiscal_year,  -- Select the fiscal year
        vehicle_category,  -- Select the vehicle category
        CASE  
            WHEN vehicle_category = '2-Wheelers' THEN electric_vehicles_sold * 85000  -- Calculate revenue for 2-Wheelers (85,000 per vehicle)
            WHEN vehicle_category = '4-Wheelers' THEN electric_vehicles_sold * 1500000  -- Calculate revenue for 4-Wheelers (1,500,000 per vehicle)
        END AS total_revenue  -- Store the calculated revenue in a new column
    FROM 
        joined_data  -- Use the joined data from Step 1
)

-- Step 3: Calculate the revenue growth rate for each vehicle category and state between 2022-2024 and 2023-2024
SELECT 
    state,  -- Select the state
    vehicle_category,  -- Select the vehicle category
    ROUND(((total_revenue_2024 - total_revenue_2022) / total_revenue_2022) * 100, 2) AS growth_rate_2022_2024,  -- Calculate the growth rate from 2022 to 2024
    ROUND(((total_revenue_2024 - total_revenue_2023) / total_revenue_2023) * 100, 2) AS growth_rate_2023_2024  -- Calculate the growth rate from 2023 to 2024
FROM (
    SELECT 
        state,  -- Select the state
        vehicle_category,  -- Select the vehicle category
        MAX(CASE WHEN fiscal_year = 2022 THEN total_revenue END) AS total_revenue_2022,  -- Capture the revenue for 2022
        MAX(CASE WHEN fiscal_year = 2023 THEN total_revenue END) AS total_revenue_2023,  -- Capture the revenue for 2023
        MAX(CASE WHEN fiscal_year = 2024 THEN total_revenue END) AS total_revenue_2024  -- Capture the revenue for 2024
    FROM 
        revenue_data  -- Use the revenue data from Step 2
    GROUP BY 
        state,  -- Group by state
        vehicle_category  -- Group by vehicle category
) AS growth_rates  -- Name the subquery result as growth_rates
ORDER BY 
    state;  -- Order the final result by state

   