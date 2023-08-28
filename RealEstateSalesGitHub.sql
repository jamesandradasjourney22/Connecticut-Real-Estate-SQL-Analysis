-- Conneticut Real Estate Data Cleaning, Exploration, and Analysis

-- Creation of database for analysis 
CREATE DATABASE real_estate_db;
USE real_estate_db;


-- Data cleaning & exploration

-- 1.Renaming columns
ALTER TABLE `real_estate_db`.`realestatesales` 
CHANGE COLUMN `Serial Number` `serial_number` INT NULL DEFAULT NULL ,
CHANGE COLUMN `List Year` `list_year` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Date Recorded` `date_recorded` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Town` `town` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Address` `address` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Assessed Value` `assessed_value` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Sale Amount` `sale_amount` INT NULL DEFAULT NULL ,
CHANGE COLUMN `Sales Ratio` `sales_ratio` DOUBLE NULL DEFAULT NULL ,
CHANGE COLUMN `Property Type` `property_type` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `Residential Type` `residential_type` TEXT NULL DEFAULT NULL ;


-- 2. Changing data types  
-- 2A1. Converting 'date_recorded' column to DATE datatype & creating a new column called 'new_date_recorded'
ALTER TABLE realestatesales
ADD new_date_recorded DATE;

-- 2A2. Inserting formatted dates into  'new_date_recorded' column
UPDATE realestatesales
SET new_date_recorded = 
    CASE
        WHEN date_recorded = '' THEN NULL         -- Handle empty strings
        WHEN date_recorded IS NULL THEN NULL     -- Handle NULL values
        ELSE STR_TO_DATE(date_recorded, '%m/%d/%y')
    END;

-- 2A2. Dropping original column called 'date_recorded' and renaming 'new_date_recorded' to be called 'date_recorded'
ALTER TABLE realestatesales
DROP Column date_recorded;

ALTER TABLE realestatesales
RENAME COLUMN new_date_recorded TO date_recorded;

-- Ensuring that their isn't one (or multiple) years where the number of sales dominate.
SELECT DISTINCT
    COUNT(*) AS 'Count', list_year AS 'Year'
FROM
    realestatesales
GROUP BY list_year
ORDER BY list_year DESC;


-- By exploring serial numbers, it's clear that properties situated close to each other tend to have more similar serial number patterns. This suggests a link between how near properties are to each other and how their serial numbers appear, offering an interesting aspect to the dataset's insights.
SELECT * FROM realestatesales
ORDER BY serial_number DESC;


-- 2. The following SQL query checks whether there are duplicate entries within the dataset. There are 0 duplicate entries within the dataset. 
SELECT 
	serial_number, list_year, town, address, assessed_value, sale_amount
    sales_ratio, property_type, residential_type, COUNT(*) as duplicate_count
FROM realestatesales
GROUP BY 
	serial_number, list_year, town, address, assessed_value, sale_amount,
    sales_ratio, property_type, residential_type
HAVING COUNT(*) > 1;


-----------------------------------------------------------
-- Conneticut real estate data insights


-- 1. Average property sale amount over the years.
SELECT 
	list_year, FORMAT(AVG(sale_amount),2) AS avg_sale_amount
FROM realestatesales
GROUP BY list_year
ORDER BY list_year;


-- 2. How many of each property type was sold from 2001-2020?
SELECT property_type, COUNT(*) AS sales_count
FROM realestatesales
GROUP BY property_type
ORDER BY sales_count DESC;


-- LIMITATION OF DATASET: The data set comprises 382,446 rows where the property type is indicated as an empty space (''). 
SELECT FORMAT(COUNT(*),0) FROM realestatesales
WHERE property_type = '';


-- LIMITATION OF DATASET: The dataset comprises 388,304 rows where the residential type is indicated as an empty space (''). Furthermore, there are an additional 4 rows in the dataset where the residential type is marked as NULL.
SELECT DISTINCT
    residential_type, FORMAT(COUNT(*),0) AS residential_type_count
FROM
    realestatesales
GROUP BY residential_type
;


-- 3. Average assessed value by property type
SELECT property_type, FORMAT(AVG(assessed_value),2) AS avg_assessed_value
FROM realestatesales
GROUP BY property_type
ORDER BY avg_assessed_value DESC;

-- LIMITATION OF DATA/ DATA ENTRY ERROR: The average assessed value for properties categorized with an empty space ('') as their property type is $316,329.67. It would be beneficial to determine the specific property types associated with these instances, as this could provide additional insights about the data.


-- 4. High sales-ratio properties
-- Definition/exlanation: An optimal sales ratio typically falls within the range of 1 to 2. A higher ratio signifies that the market demonstrates a willingness to allocate more dollars for each unit of annual sales, suggesting a potentially robust demand for the property.

-- LIMITATION OF DATA or POTENTIAL DATA ENTRY ERROR and/or POTENTIAL OUTLIERS: A total of 6048 properties within the dataset exhibit a sales ratio exceeding 20. This observation prompts consideration of potential outliers or data input anomalies, which could contribute to such higher-than-expected sales ratios.
SELECT town, address, sale_amount, assessed_value, sales_ratio
FROM realestatesales
WHERE sales_ratio > 1.5
ORDER BY sales_ratio DESC;

SELECT COUNT(*) 
FROM realestatesales
WHERE sales_ratio > 20;

-- LIMITATION OF DATA or POTENTIAL DATA ENTRY ERROR: The dataset's owner stipulated the inclusion of real estate sales listings with sale prices exceeding $2000. However, the dataset currently contains 2,139 records with sale prices below this threshold. Among these records, 1,871 instances feature sale prices below $100. Given the unusual nature of real estate transactions involving sale prices below $100, it is advisable to thoroughly investigate these specific records for potential anomalies or irregularities.

-- The number of properties where the sale amount was less than $2000.
SELECT COUNT(*) FROM realestatesales
WHERE sale_amount < 2000;

-- The number of properties where the sale amount was less than $100.
SELECT COUNT(*) FROM realestatesales
WHERE sale_amount < 100;

-- The provided query presents the properties (a total of 2,139) that were sold with amounts below $2,000 ordered by the sale amount in descending order.
SELECT * 
FROM realestatesales
WHERE sale_amount < 2000
ORDER BY sale_amount DESC;

-- POTENTIAL DATA ENTRY ERROR: A notable number of properties exhibit exceptionally high sales ratios, yet these properties lack both a designated property type and a specified residential type. The presence of an assessed value for real estate without defined property or residential classifications prompts inquiry into the rationale behind such classification.

SELECT property_type, residential_type, sales_ratio, assessed_value
FROM realestatesales
WHERE property_type = ''
ORDER BY sales_ratio DESC;

SELECT * FROM realestatesales
ORDER BY sales_ratio DESC;


-- 5. Yearly Sales Trends: The number of real estate sales each year.
SELECT list_year, FORMAT(COUNT(*),0) AS sales_count
FROM realestatesales
GROUP BY list_year
ORDER BY list_year;


-- 6. Most expensive property sales
SELECT town, address, residential_type, list_year, FORMAT(sale_amount,2)
FROM realestatesales
ORDER BY sale_amount DESC
LIMIT 2000;

-- POTENTIAL DATA ENTRY ERROR: The scenario where numerous properties within close proximity on the same street achieve substantial pricing levels poses a challenging perspective. Furthermore, the inclusion of asterisks or hashtags within select addresses, which frequently signify unit-based properties like apartments, condos, and office spaces, introduces intricacies to comprehending these transactions. With this, the idea of individual units attaining sales in the tens or hundreds of millions of dollars instigates inquiries that warrant a thorough investigation. The subsequent SQL queries provide specific instances for reference.

-- 6A Example 1: It's quite surprising to find multiple properties along the same road with valuations exceeding $72,000,000. To enhance credibility, one might find it more plausible that the property situated at 93 Glenbrook Road has an overall valuation of $72,000,000, with each individual unit holding a distinct, likely lower, value. To improve the representation of this, you might consider omitting the sale amounts for each individual unit within the same property, and instead, opt to either retain only the building's address or accurately adjust the sale amounts to reflect the true worth of each property unit. Run the following query to see the example. 
SELECT town, address, FORMAT(sale_amount,2), property_type
FROM realestatesales 
WHERE address LIKE '93 GLENBROOK ROAD%';


-- 6A Example 2: Again, it quite surprising to find multiple properties along the same road with $395,000,000 valuations. Consider taking similar approach as stated in the 1st example  of 6A. 
SELECT town, address, FORMAT(sale_amount,2), property_type
FROM realestatesales 
WHERE address LIKE '%Henry Street%'
ORDER BY sale_amount DESC;


-- 7. Average sale amount by residential Type
SELECT residential_type, FORMAT(AVG(sale_amount),2) AS avg_sale_amount
FROM realestatesales
GROUP BY residential_type
ORDER BY avg_sale_amount DESC;

-- Data Entry Error: The dataset presents an intriguing finding: the average sale amount for properties categorized with a residential type of an empty space ('') is calculated at $423,099.28. Delving deeper into the data entry that led to this figure could unveil valuable insights and shed light on the underlying factors contributing to this unexpected number. Furthermore, as stated earlier, there are four properties with a NULL value in the residential_type field. These four properties exhibit an average sale amount of $127,100. This particular observation warrants investigation, as the absence of residential type information alongside the distinct average sale amount for these properties could potentially reveal a unique market trend or data phenomenon deserving of closer examination.


-- 8. High-value sales by year and property type
SELECT list_year, property_type, MAX(sale_amount) AS max_sale_amount
FROM realestatesales
GROUP BY list_year, property_type
ORDER BY list_year, max_sale_amount DESC;

-- DATA LIMITATION ERROR or DATA ENTRY ERROR: Property type denoted as an empty space.


-- 9.Yearly property type distribution
SELECT list_year, property_type, COUNT(*) AS sales_count
FROM realestatesales
GROUP BY list_year, property_type
ORDER BY list_year, sales_count DESC;
-- DATA LIMITATION ERROR or DATA ENTRY ERROR: Property type denoted as an empty space.



-- 10.  Sale Amount Distribution By Sales Range
SELECT FLOOR(sale_amount / 100000) * 100000 AS sale_range,
       COUNT(*) AS sales_count
FROM realestatesales
GROUP BY sale_range
ORDER BY sale_range;
-- After analyzing the result set, it's evident that the distribution of sale amounts by sales range follows an anticipated right-skewed pattern. This means that as the property sale amount increased, the number of properties sold decreased, aligning with typical real estate market trends.


-- 11. 3-Year Moving Average for Yearly # of Properties Sold
SELECT
    year,
    AVG(sales_count) OVER (ORDER BY year ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS moving_avg_3_years
FROM (
    SELECT
        EXTRACT(YEAR FROM date_recorded) AS year,
        COUNT(*) AS sales_count
    FROM realestatesales
    WHERE (EXTRACT(YEAR FROM date_recorded) BETWEEN 2001 AND 2020) AND date_recorded >= list_year AND date_recorded IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM date_recorded)
) yearly_sales;
-- POTENTIAL DATA ENTRY ERROR/ DATA DISCREPANCY: A total of 56 instances were identified in the dataset where the recorded sale date precedes the property's listing date, indicating a noteworthy data anomaly where sale transactions appear to have been recorded prior to the property being officially listed. Furthermore, within the dataset, two rows feature NULL values in the recorded date field. Given this circumstance, and in preparation for calculating three-year moving averages to glean insights into yearly sales trends, I opted to exclude these rows from my calculation above.



-- The following queries provides details concerning dataset records where property listings come before property sales, accompanied by a quantification of the frequency of such events.
SELECT serial_number, list_year,date_recorded, town, address, assessed_value, sales_ratio, property_type,
	residential_type
FROM realestatesales
WHERE EXTRACT(YEAR FROM date_recorded) < list_year;

SELECT count(*)
FROM realestatesales
WHERE EXTRACT(YEAR FROM date_recorded) < list_year;


-- 12. Cohort Analysis Using Town As The Cohort
-- Cohort Analysis Definition: A type of behavioral analysis that breaks data into related groups before analysis. These groups typically share common characteristics within a defined time-span. In this case, the cohort is the town and the time-span is the year the property was sold. 

-- In the example below, we are analyzing the distribution of property types for each town over time. This will allow you to see how property type preferences evolve within different towns.
SELECT
    town,
    property_type,
    EXTRACT(YEAR FROM date_recorded) AS sales_year,
    COUNT(*) AS properties_sold
FROM realestatesales
WHERE EXTRACT(YEAR FROM date_recorded) >= list_year
GROUP BY town, property_type, EXTRACT(YEAR FROM date_recorded)
ORDER BY town, property_type, EXTRACT(YEAR FROM date_recorded);

-- DATA ENTRY ERROR: In the dataset, there's one record without a specified town. However, with a quick inquiry (using google search), it's clear that the correct town is East Hampton, Connecticut. The following queries highlight the specific record labeled as "***unknown***" for the town and correct it by changing it to the accurate town, East Hampton.
SELECT *
FROM realestatesales
where town = '***Unknown***';

UPDATE realestatesales
SET town = 'East Hampton'
WHERE town = '***Unknown***';

------------------------------------------------------------



