-- Exploratory Data Analysis

SELECT *
from layoffs_staging2;

-- Retrieve Maximum Values
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
from layoffs_staging2;

-- Identify Companies with 100% Layoffs
select *
from layoffs_staging2
WHEre percentage_laid_off = 1
order by funds_raised_millions DESC;

-- Group Total Layoffs by Company
select company, sum(total_laid_off)
from layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Time range to determine the time period for the earliest and latest layoffs
SELECT MIN(`date`), MAX(`date`)
from layoffs_staging2;

-- Group Total Layoffs by Industry
select industry, sum(total_laid_off)
from layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Group Total Layoffs by Country
select country, sum(total_laid_off)
from layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Group Total Layoffs by Year
select year(`date`), sum(total_laid_off)
from layoffs_staging2
GROUP BY year(`date`)
ORDER BY 1 DESC;

-- Group Total Layoffs by stage (type of company)
select stage, sum(total_laid_off)
from layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average Layoff by company 
select company, avg(percentage_laid_off)
from layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Analysing Monthly Layoffs
select substring(`date`, 1, 7) AS `Month`, SUM(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) IS NOT NULL
GROUP by `Month`
order by 1 ASC;

-- CTE for Rolling Totals
with Rolling_Total AS 
(
select substring(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS total_off
from layoffs_staging2
where substring(`date`, 1, 7) IS NOT NULL
GROUP by `Month`
order by 1 ASC
)
SELECT `Month`, total_off,
SUM(total_off) over (order by `Month`) as rolling_total
FROM Rolling_Total;

-- Layoffs per company per year, from largest to smallest total layoff
select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
GROUP BY company, YEAR(`date`)
order by 3 DESC;

-- Selecting Top 5 Companies with Highest Layoffs per Year
WITH company_year (company, years, total_laid_off) AS
(
select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_year_rank AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_year_rank
WHERE ranking <= 5;
