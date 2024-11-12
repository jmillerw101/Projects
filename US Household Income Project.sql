# US Household Income Data Cleaning

SELECT *
FROM us_project.us_household_income;

SELECT * 
FROM us_project.us_household_income_statistics;

ALTER TABLE us_project.us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`;

SELECT COUNT(id)
FROM us_project.us_household_income;                # Running these queries together will allow us to compare the number of rows returned from each, letting us know how many were omitted during import. 
													# import errors happen often in MySQL if the data is raw / dirty

SELECT COUNT(id)
FROM us_project.us_household_income_statistics;

SELECT id, COUNT(id)                     #This is how we determine if there are duplicates of an ID
FROM us_project.us_household_income
GROUP BY id
HAVING COUNT(id) > 1
;

SELECT row_id,                                        
id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id)
FROM us_project.us_household_income
;                                          # We can't filter down this query with a GROUP by because of the our 'ROW_NUMBER() OVER(PARTITION BY id ORDER BY id)' column, so we will have to use it as a subquery in the 
                                           # FROM statement. V

SELECT row_id
	FROM (
		SELECT row_id,                                        
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM us_project.us_household_income
		) dupliactes                 # <--- MUST ALIAS THIS CREATED TABLE
	WHERE row_num > 1
;

DELETE FROM us_household_income          #This entire query deleted all of our diplicate rows from the table
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id,                                        
		id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM us_project.us_household_income
		) dupliactes                 # <--- MUST ALIAS THIS CREATED TABLE
	WHERE row_num > 1
)
;



SELECT id, COUNT(id)                     #This is how we determine if there are duplicates of an ID
FROM us_project.us_household_income_statistics   #There are not any duplicates in this other table though
GROUP BY id
HAVING COUNT(id) > 1
;


SELECT State_Name, COUNT(State_Name)     
FROM us_project.us_household_income
GROUP BY State_Name
;


SELECT DISTINCT State_Name 
FROM us_project.us_household_income
ORDER BY 1
;

UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE us_project.us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;

SELECT DISTINCT *
FROM us_project.us_household_income
WHERE Place = ''
ORDER BY 1
;

SELECT DISTINCT *
FROM us_project.us_household_income
WHERE County = 'Autauga County'
ORDER BY 1
;

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont'
;


SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type
;


UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs'
;

SELECT DISTINCT ALand, AWater
FROM us_household_income
WHERE (AWater = 0 OR AWater = NULL OR AWater = '')
AND (ALand = 0 OR ALand = NULL OR ALand = '')
;

SELECT DISTINCT ALand, AWater
FROM us_household_income
WHERE (ALand = 0 OR ALand = NULL OR ALand = '')
;

##############################################################################

# US Household Income Exploratory Data Analysis


SELECT *
FROM us_project.us_household_income;

SELECT * 
FROM us_project.us_household_income_statistics;


SELECT State_Name, ALand, AWater
FROM us_project.us_household_income
;


SELECT State_Name, SUM(ALand), SUM(AWater)  #This query will return us the top 10 states with the most area of water
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;


SELECT *
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
;

SELECT *
FROM us_project.us_household_income u
RIGHT JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE u.id IS NULL
;

SELECT *
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
;


SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
;


SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 3 DESC
LIMIT 10
;


SELECT Type, COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
WHERE Mean <> 0
GROUP BY 1
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
LIMIT 20
;


SELECT *
FROM us_household_income
WHERE Type = 'Community'
;


SELECT u.State_Name, City, ROUND(AVG(Mean),1),ROUND(AVG(Median),1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	ON u.id = us.id
GROUP BY u.State_Name, City
ORDER BY ROUND(AVG(Mean),1) DESC
;











































