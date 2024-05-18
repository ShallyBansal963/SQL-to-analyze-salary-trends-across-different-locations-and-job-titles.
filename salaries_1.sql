- Analyzing Remote Work Opportunities for Managerial Positions

/*. 1. As a Compensation Analyst at a multinational corporation, I am tasked with identifying companies that offer fully 
remote work for managerial positions with salaries exceeding $90,000 USD. This analysis helps our organization understand
 market trends and benchmark our compensation packages accordingly.*/
 
USE Project1;
SELECT DISTINCT company_location 
FROM salaries 
WHERE job_title LIKE '%manager' 
AND salary_in_usd > 90000 
AND remote_ratio = 100;
-- Identifying Top Countries for Fresher Opportunities in Large Tech Firms

/*As a remote work advocate at a progressive HR Tech startup, I am committed to placing our fresher clients in top-tier tech 
firms around the world. To better understand where these opportunities are most abundant, I conducted an analysis to identify
the top 5 countries with the highest number of large companies hiring freshers.*/

SELECT company_location, COUNT(*) AS cnt 
FROM salaries 
WHERE experience_level = 'EN' 
AND company_size = 'L' 
GROUP BY company_location 
ORDER BY cnt DESC 
LIMIT 5;

/*  Objective: As a data scientist working at a workforce management platform,
   calculate the percentage of employees with fully remote roles and salaries 
   exceeding $100,000 USD. This highlights the attractiveness of high-paying
   positions in today's job market. */
   
/* Calculate the total number of employees with salaries exceeding $100,000 USD */
SET @total_high_salary = (
    SELECT COUNT(*)
    FROM salaries
    WHERE salary_in_usd > 100000
);
/* Calculate the number of employees with fully remote roles and salaries exceeding $100,000 USD */
SET @fully_remote_high_salary = (
    SELECT COUNT(*)
    FROM salaries
    WHERE remote_ratio = 100
	AND salary_in_usd > 100000
);
/* Calculate the percentage of fully remote employees with high salaries */
SELECT 
 ROUND((@fully_remote_high_salary / @total_high_salary) * 100, 2) AS percentage_fully_remote_high_paid_employees;
-- another mathod 
DELIMITER //
CREATE PROCEDURE CalculateRemoteHighSalaryPercentage()
BEGIN
    DECLARE total_high_salary INT;
    DECLARE fully_remote_high_salary INT;
    DECLARE percentage_fully_remote_high_paid_employees DECIMAL(5, 2);
    
/* Calculate the total number of employees with salaries exceeding $100,000 USD */
    SELECT COUNT(*)
    INTO total_high_salary
    FROM salaries
    WHERE salary_in_usd > 100000;
    
    /* Calculate the number of employees with fully remote roles and salaries exceeding $100,000 USD */
    SELECT COUNT(*)
    INTO fully_remote_high_salary
    FROM salaries
    WHERE remote_ratio = 100
      AND salary_in_usd > 100000;
      /* Calculate the percentage of fully remote employees with high salaries */
    SET percentage_fully_remote_high_paid_employees = ROUND((fully_remote_high_salary / total_high_salary) * 100, 2);
/* Select the result */
    SELECT percentage_fully_remote_high_paid_employees AS percentage_fully_remote_high_paid_employees;
END //
DELIMITER ;
-- Call the procedure to see the result
CALL CalculateRemoteHighSalaryPercentage();

/* 
   Objective: As a data analyst for a global recruitment agency,
   identify locations where the average entry-level salary exceeds
   the average market salary for entry-level positions. This helps
   guide candidates towards lucrative opportunities.  */

-- Calculate the average market salary for each entry-level job title
WITH avg_market_salary AS (
    SELECT 
        job_title, 
        AVG(salary) AS avg_salary_market
    FROM 
        salaries
    WHERE 
        experience_level = 'EN'
    GROUP BY 
        job_title
),
-- Calclate the average salary for each entry-level job title at each location
avg_location_salary AS (
    SELECT 
        company_location, 
        job_title, 
        AVG(salary) AS avg_salary_loc
    FROM 
        salaries
    WHERE 
        experience_level = 'EN'
    GROUP BY 
        company_location, 
        job_title
)

-- Select locations where the average salary exceeds the market average for the same job title
SELECT 
    als.company_location, 
    als.job_title, 
    als.avg_salary_loc, 
    ams.avg_salary_market
FROM 
    avg_location_salary als
INNER JOIN 
    avg_market_salary ams
ON 
    als.job_title = ams.job_title
WHERE 
    als.avg_salary_loc > ams.avg_salary_market;


/* Objective: As a data analyst for an HR consultancy, find out which country pays the highest average salary
   for each job title. This information helps in placing candidates in those lucrative countries. */
USE Project1;
-- Calculate the average salary for each job title by country and rank them
WITH RankedSalaries AS (
    SELECT 
        company_location, 
        job_title, 
        AVG(salary) AS avg_salary,
        DENSE_RANK() OVER (PARTITION BY job_title ORDER BY AVG(salary) DESC) AS rank1
    FROM 
        salaries
    GROUP BY 
        company_location, 
        job_title
)
-- Select the countries with the highest average salary for each job title
SELECT 
    company_location, 
    job_title, 
    avg_salary
FROM 
    RankedSalaries
WHERE 
    rank1 = 1;
    
    /*  Objective: As a data-driven business consultant, identify locations where the average salary has 
   consistently increased over the past three years, providing insights into sustained salary growth.  */

-- Step 1: Filter locations with salary data available for the past 3 years
WITH CTA_1 AS (
    SELECT * 
    FROM salaries 
    WHERE company_location IN (
        SELECT company_location 
        FROM (
            SELECT 
                company_location, 
                COUNT(DISTINCT work_year) AS cnt 
            FROM salaries
            WHERE work_year >= YEAR(CURRENT_DATE()) - 2
            GROUP BY company_location 
            HAVING cnt = 3
        ) t
    )
),

-- Step 2: Calculate the average salary for each location and year
avg_salaries AS (
    SELECT 
        company_location, 
        work_year, 
        AVG(salary_in_usd) AS average_salary 
    FROM CTA_1
    GROUP BY company_location, work_year
),

-- Step 3: Pivot the data to get average salaries for each of the three years in separate columns
pivoted_salaries AS (
    SELECT 
        company_location,
        MAX(CASE WHEN work_year = YEAR(CURRENT_DATE()) - 2 THEN average_salary END) AS avg_salary_2_years_ago,
        MAX(CASE WHEN work_year = YEAR(CURRENT_DATE()) - 1 THEN average_salary END) AS avg_salary_1_year_ago,
        MAX(CASE WHEN work_year = YEAR(CURRENT_DATE()) THEN average_salary END) AS avg_salary_current_year
    FROM avg_salaries
    GROUP BY company_location
)

-- Step 4: Select locations with consistent salary growth over the past three years
SELECT 
    company_location,
    avg_salary_2_years_ago AS avg_salary_2022,
    avg_salary_1_year_ago AS avg_salary_2023,
    avg_salary_current_year AS avg_salary_2024
FROM pivoted_salaries
WHERE 
    avg_salary_current_year > avg_salary_1_year_ago 
    AND avg_salary_1_year_ago > avg_salary_2_years_ago;

















