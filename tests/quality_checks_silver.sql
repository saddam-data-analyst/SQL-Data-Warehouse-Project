/*
===========================================================================
Quality Checks
===========================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and Standardization across the 'silver' schema. It includes checks for:
    - Null Or Duplicate primary Keys.
    - Unwanted Spaces in string fields.
    - Data Standardization and consistency.
    - Invalid Date Range and Orders.
    - Data Consistency between related fileds.


Usage Note:
  - Run this checks after data loading silver layer.
  - Investigate and resolve any discrepencies found during the checks.
============================================================================
*/

============================================================================
Checking 'silver.crm_cust_info'
============================================================================


-Steps for Silver Tables
--Check For Nulls(Must be Unique) or Duplicates in primary key
--Expectation: No Result

SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


SELECT
prd_id,
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

======================================================================

--Check for unwanted spaces
--Expectation: No Result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
=======================================================================
  
--Check for Nulls or Negative Numbers
--Expectation: No Results
--Check for unwanted spaces
--Expectation: No Result
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
======================================================================

--Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
======================================================================
  
--Check fro invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT * FROM silver.crm_prd_info
========================================================

--Check Data Consistency: Between Sales, Quantity and Price
-->> Sales = Quantity * Price
-->> Values must not be null, zero or Negative.
SELECT DISTINCT
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
--Rules: If Sales is negative, zero, or null, derive it Quantity and Price
 --    : If Price is zero or null, Calculate it using Sales and Quantity,
 --    : If Price is negative, convert it to a positive value
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,

	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price

FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL 
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price
=========================================================================
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL 
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details
============================================================================

--Checking for Invalid Date Orders
SELECT
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_ship_dt
===========================================================================


--Identify Out_of-Range Dates

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--Data Standardization & Consistency
SELECT DISTINCT 
gen
FROM silver.erp_cust_az12

SELECT * FROM silver.erp_cust_az12
