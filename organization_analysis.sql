CREATE DATABASE organization_analysis; 
USE organization_analysis;

CREATE TABLE organizations (
idx INT,
organization_id VARCHAR(50),
name VARCHAR(255),
website VARCHAR(255),
country VARCHAR(255),
description TEXT,
founded INT,
industry VARCHAR(150),
number_of_employees INT
);

SELECT * FROM organizations LIMIT 10;

-- Q1: WHAT PERCENTAGE OF ORGANIZATION AREVCONTRIBUTED BY EACH COUNTRY?
SELECT
      country, 
      COUNT(*) AS org_count, 
      ROUND(
            COUNT(*)*100.0/(SELECT COUNT(*) FROM organizations),
            2) AS percentage_contribution FROM organizations GROUP BY country ORDER BY percentage_contribution DESC;
            
            
-- Q2: WHICH INDUSTRY IS THE MOST DOMINANT INDUSTY IN EACH COUNTRY?
SELECT country, industry, total_orgs
From(
     SELECT country, industry,
	        COUNT(*) AS total_orgs,
            RANK() OVER (PARTITION BY country ORDER BY COUNT(*) DESC) AS rnk FROM organizations GROUP BY country, industry
            ) ranked WHERE rnk =1;
            

-- Q3. WHICH INDUSTY CONTRIBUTE THE HIGHEST TOTAL WORKFORCE?
SELECT industry,
       SUM(number_of_employees) AS total_employees FROM organizations 
       GROUP BY industry 
       ORDER BY total_employees DESC;
       
       
-- Q4: HOW MANY COMPANIES FALL INTO SMALL/MEDIUM/LARGE CATEGORIES?
SELECT 
    CASE 
        WHEN number_of_employees < 100 THEN 'Small'
        WHEN number_of_employees BETWEEN 100 AND 1000 THEN 'Medium'
        ELSE 'Large'
    END AS company_size,
    COUNT(*) AS total_companies
FROM organizations
GROUP BY company_size
ORDER BY total_companies DESC;


-- Q5: WHAT IS THE AVERAGE AGE OF COMPANIES BY INDUSTRY?
SELECT 
    industry,
    ROUND(AVG(YEAR(CURDATE()) - founded), 1) AS avg_company_age
FROM organizations
GROUP BY industry
ORDER BY avg_company_age DESC;


-- Q6: WHICH YEARS SAW UNUSUALLY HIGH ORGANIZATION FORMATION?
SELECT founded, COUNT(*) AS org_count
FROM organizations
GROUP BY founded
HAVING COUNT(*) > (
    SELECT AVG(year_count)
    FROM (
        SELECT COUNT(*) AS year_count
        FROM organizations
        GROUP BY founded
    ) temp
)
ORDER BY founded;

-- Q7: TOP 3 LARGEST ORGANIZATIONS IN EACH COUNTRY?
SELECT country, name, number_of_employees
FROM (
    SELECT 
        country,
        name,
        number_of_employees,
        DENSE_RANK() OVER (
            PARTITION BY country 
            ORDER BY number_of_employees DESC
        ) AS rnk
    FROM organizations
) ranked
WHERE rnk <= 3;


-- Q8: WHICH COUNTRIES HAS THE MOST DIVERSE COUNTRY?
SELECT 
    country,
    COUNT(DISTINCT industry) AS industry_diversity
FROM organizations
GROUP BY country
ORDER BY industry_diversity DESC;