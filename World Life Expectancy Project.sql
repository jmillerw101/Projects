# World Life Expectancy Project (Data Cleaning)



SELECT * 
FROM world_life_expectancy
;

#Data missing in `Status` and `Life expectancy`

# We'll start cleaning the data by identifying and removing any duplicate rows

#The query below will concatenate the country and year columns, and run a count on the outputs. If there are any counts greater than 1, which means there is a duplicate row, the query will return those duplicate rows.

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

# Now we need to identify the Row_ID of each duplicate so that we can remove them

# If we try to filter on the below query, it will throw an error. We will have to use this query as a subquery in the FROM statement
SELECT Row_ID, 
CONCAT(Country, Year),
ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
FROM world_life_expectancy
;

# Must add an alias for the created table or it will error
SELECT *
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy) AS Row_table
WHERE Row_Num > 1
;


DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
	SELECT Row_ID 
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy) AS Row_table
WHERE Row_Num > 1
)
;

##################################

# Next we are going to assess how many blanks or NULL's are in the `Status` column

SELECT * 
FROM world_life_expectancy
WHERE Status = ''
;


SELECT DISTINCT(Status)              # SELECt DISTINCT statement is used to return only distinct (different) values
FROM world_life_expectancy
WHERE Status <> ''
;


SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

UPDATE world_life_expectancy    # DOES NOT WORK 
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(Country)
				  FROM world_life_expectancy
				  WHERE Status = 'Developing'
)
;

UPDATE world_life_expectancy t1    # Using this self joint, we are able to filter based on the joined table
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;


SELECT * 
FROM world_life_expectancy
WHERE Country = 'United States of America'
;

UPDATE world_life_expectancy t1    # Using this self joint, we are able to filter based on the joined table
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

#########################



SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;


SELECT Country, Year,`Life expectancy` 
FROM world_life_expectancy
#WHERE `Life expectancy` = ''
;


SELECT Country, Year,`Life expectancy`  # This query will throw an error because we need to identify which table each of the columns in the select statement is coming from
FROM world_life_expectancy t1
Join world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
;


SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,    
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy` ) / 2, 1)
FROM world_life_expectancy t1
Join world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
Join world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;


UPDATE world_life_expectancy t1 
Join world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
Join world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy` ) / 2, 1)
WHERE  t1.`Life expectancy` = ''
;

#######################################################################################################################################


# World Life Expectancy Project (Exploratory Data Analysis)

SELECT * 
FROM world_life_expectancy
;


SELECT Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`)-MIN(`Life expectancy`), 1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years ASC
;


SELECT Year, 
ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0   # Excludes any years that have a life expectancy value of 0, that way our world averages are not brought down. Change the 'HAVING' keyword to 'WHERE', since HAVING is used in congunction 
AND `Life expectancy` <> 0     # with aggregate functions. GROUP BY also is moved after the WHERE statement, where it is supposed to be.
GROUP BY Year
ORDER BY Year
;


SELECT * 
FROM world_life_expectancy
;


SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP DESC
;


SELECT                               
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,                                # This CASE statement will output the number of contries that have a GDP over 1500 (million)                    
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_Expectancy,    # This CASE statement will output the avg life expectancy of these high GDP countries
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,                                # This CASE statement will output the number of contries that have a GDP over 1500 (million)                    
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;


SELECT * 
FROM world_life_expectancy
;


SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;


SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI ASC
;


SELECT Country,      # Rolling total using a window function
Year, 
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE '%United%'
;


### Find total population online and import the data it to this table








































