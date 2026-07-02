-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove any columns or rows

-- create staging table to not work on raw table
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Duplicates
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper'; 

-- This wont work because MySQL doesnt allow to modify CTE, since they are read only, without a unique identifier to match rows back to the base table
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, location, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS ROW_NUM
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- Creating another table to delete duplicate  and continue its work on this table

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, location, total_laid_off, 
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Standardize Data

SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT distinct industry
FROM layoffs_staging2
order by 1;

SELECT distinct industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT distinct industry
FROM layoffs_staging2
ORDER BY 1;

SELECT distinct country
FROM layoffs_staging2
order by 1;

-- locating commas, spaces or dots at the end of text with trailing
SELECT distinct country, trim(Trailing '.' FROM country)
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET country = trim(Trailing '.' FROM country)
WHERE country LIKE 'United States%';

SELECT distinct country, trim(Trailing '.' FROM country)
FROM layoffs_staging2
order by 1;

SELECT distinct location, trim(location)
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET location = trim(location);

SELECT distinct location
FROM layoffs_staging2
order by 1;

UPDATE layoffs_staging2
SET location = CASE
    WHEN location LIKE '%sseldorf' THEN 'Düsseldorf'
    WHEN location LIKE 'Malm%' THEN 'Malmo'
    WHEN location LIKE 'Florian%' THEN 'Florianópolis'
END
WHERE location LIKE '%sseldorf'
   OR location LIKE 'Malm%'
   OR location LIKE 'Florian%';

SELECT distinct location
FROM layoffs_staging2
order by 1;


-- date format
SELECT `date`
from layoffs_staging2;

SELECT `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

-- never do this on raw table
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
from layoffs_staging2;

-- FIXING SOME NULLS AND BLANK VALUES

SELECT *
from layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
from layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
from layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry is NULL or t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location;
    
 -- remove columns or rows

SELECT *
from layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
from layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

select *
from layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;