--Let's take a look of the raw data first
SELECT *
FROM PortfolioProject..monthly_search

SELECT *
FROM PortfolioProject..avg_CTR

--Some of the columns are empty or have info that we don't need, so we create two new tables with the data we are interested on

SELECT Keyword, [Avg# monthly searches], [Competition (indexed value)]
INTO monthly_search_clean
FROM PortfolioProject..monthly_search

SELECT Keyword, [Estimated CTR], [Estimated Clicks]
INTO avg_CTR_clean
FROM PortfolioProject..avg_CTR

--Now we have to drop the rows with Null or 0 values. 
--These values means that these keywords does not have enought search every month.
--It is a common mistake to take all the keywords and work with them, instade of focus the strategy on the relevant ones.


DELETE 
FROM avg_CTR_clean
WHERE [Estimated CTR] IS NULL

DELETE 
FROM monthly_search_clean
WHERE [Avg# monthly searches] IS NULL

--We can see than all the NULL values in Avg # monthly search are gone, but there are NULL values in the Competition column
--We will replace them with a 0. the reason is than we will use the avg searches to define the SEO strategy, 
--Competition index is just some extra information than could become important only in some situations, 
--so we need to keep the keywords even if they don't have a competition index

UPDATE monthly_search_clean
SET [Competition (indexed value)]= ISNULL([Competition (indexed value)], 0)

--Now we have to join these tables on the keywords. 
--First, we create 2 new columns in the avg_monthly_search table, to fill with the clicks and CTR values of each keyword

ALTER TABLE monthly_search_clean
ADD Estimated_Clicks float

ALTER TABLE monthly_search_clean
ADD Estimated_CTR float

--Then we fill the new columns with the data from the avg_CTR_clean table

UPDATE a
SET a.[Estimated_Clicks] = b.[Estimated Clicks]
FROM monthly_search_clean a
	left join avg_CTR_clean b
	on a.Keyword=b.Keyword

UPDATE a
SET a.[Estimated_CTR] = b.[Estimated CTR]
FROM monthly_search_clean a
	left join avg_CTR_clean b
	on a.Keyword=b.Keyword

--The NULL values generated should be fill with 0.

UPDATE monthly_search_clean
SET [Estimated_CTR]= ISNULL([Estimated_CTR], 0)

UPDATE monthly_search_clean
SET [Estimated_Clicks]= ISNULL([Estimated_Clicks], 0)

--Finally, we have to categorise the keywords in groups. 

SELECT *,
CASE
	WHEN Keyword LIKE '%adiestra%' THEN 'adiestramiento'
	WHEN Keyword LIKE '%escuela%' THEN 'escuela'
	WHEN Keyword LIKE '%entrena%' THEN 'entrenamiento'
	WHEN Keyword LIKE '%educa%' THEN 'educación'
	ELSE 'otros'
END as Categoria
FROM monthly_search_clean




