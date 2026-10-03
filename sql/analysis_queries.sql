-- Supply Chain Analytics
-- SQL Analysis


-- 1. Preview the dataset
SELECT *
FROM supply_chain
LIMIT 10;


-- 2. Overall business KPIs
SELECT
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 2) AS Total_Gross_Profit,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory,
    ROUND(AVG(Absolute_Forecast_Error), 2) AS Forecast_MAE
FROM supply_chain;


-- 3. Warehouse performance
SELECT
    Warehouse_ID,
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 2) AS Total_Gross_Profit,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory
FROM supply_chain
GROUP BY Warehouse_ID
ORDER BY Total_Revenue DESC;

-- 4. Inventory reorder risk by SKU
SELECT
    SKU_ID,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory,
    ROUND(AVG(Reorder_Point), 2) AS Avg_Reorder_Point,
    SUM(Below_Reorder_Point) AS Reorder_Risk_Records,
    ROUND(AVG(Below_Reorder_Point) * 100, 2) AS Reorder_Risk_Rate
FROM supply_chain
GROUP BY SKU_ID
ORDER BY Reorder_Risk_Rate DESC
LIMIT 10;


-- 5. Supplier lead-time analysis
SELECT
    Supplier_ID,
    ROUND(AVG(Supplier_Lead_Time_Days), 2) AS Avg_Lead_Time,
    MIN(Supplier_Lead_Time_Days) AS Min_Lead_Time,
    MAX(Supplier_Lead_Time_Days) AS Max_Lead_Time,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory,
    ROUND(AVG(Below_Reorder_Point) * 100, 2) AS Reorder_Risk_Rate,
    SUM(Units_Sold) AS Total_Units_Sold
FROM supply_chain
GROUP BY Supplier_ID
ORDER BY Avg_Lead_Time DESC;


-- 6. Monthly performance and forecast accuracy
SELECT
    Month,
    SUM(Units_Sold) AS Total_Units_Sold,
    ROUND(SUM(Revenue), 2) AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 2) AS Total_Gross_Profit,
    ROUND(AVG(Inventory_Level), 2) AS Avg_Inventory,
    ROUND(AVG(Absolute_Forecast_Error), 2) AS Forecast_MAE,
    ROUND(
        SUM(Absolute_Forecast_Error) / SUM(Units_Sold) * 100,
        2
    ) AS Forecast_WAPE,
    ROUND(
        AVG(Below_Reorder_Point) * 100,
        2
    ) AS Reorder_Risk_Rate
FROM supply_chain
GROUP BY Month
ORDER BY Month;

-- 7. Rank SKUs by revenue using a CTE and window function
WITH sku_performance AS (
    SELECT
        SKU_ID,
        SUM(Units_Sold) AS Total_Units_Sold,
        SUM(Revenue) AS Total_Revenue,
        SUM(Gross_Profit) AS Total_Gross_Profit
    FROM supply_chain
    GROUP BY SKU_ID
)

SELECT
    SKU_ID,
    Total_Units_Sold,
    ROUND(Total_Revenue, 2) AS Total_Revenue,
    ROUND(Total_Gross_Profit, 2) AS Total_Gross_Profit,

    RANK() OVER (
        ORDER BY Total_Revenue DESC
    ) AS Revenue_Rank

FROM sku_performance
ORDER BY Revenue_Rank
LIMIT 10;

-- 8. Month-over-month sales change
WITH monthly_sales AS (
    SELECT
        Month,
        SUM(Units_Sold) AS Total_Units_Sold,
        SUM(Revenue) AS Total_Revenue
    FROM supply_chain
    GROUP BY Month
),

monthly_comparison AS (
    SELECT
        Month,
        Total_Units_Sold,
        Total_Revenue,

        LAG(Total_Units_Sold) OVER (
            ORDER BY Month
        ) AS Previous_Month_Units,

        LAG(Total_Revenue) OVER (
            ORDER BY Month
        ) AS Previous_Month_Revenue

    FROM monthly_sales
)

SELECT
    Month,
    Total_Units_Sold,
    Previous_Month_Units,

    ROUND(
        (Total_Units_Sold - Previous_Month_Units)
        * 100.0 / Previous_Month_Units,
        2
    ) AS Units_MoM_Change_Pct,

    ROUND(Total_Revenue, 2) AS Total_Revenue,

    ROUND(
        (Total_Revenue - Previous_Month_Revenue)
        * 100.0 / Previous_Month_Revenue,
        2
    ) AS Revenue_MoM_Change_Pct

FROM monthly_comparison
ORDER BY Month;