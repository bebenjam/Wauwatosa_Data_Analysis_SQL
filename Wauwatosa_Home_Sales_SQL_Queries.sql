
--Exploratory Analysis using Aggregate Functions for Home Prices Per ZIP Code

SELECT ZIP_Code, MAX(Price_Sold) as MaxPrice, MIN(Price_Sold) as MinPrice, AVG(Price_Sold) as AveragePrice
FROM master.dbo.Wauwatosa_Recent_Home_Sales
WHERE ZIP_Code IS NOT NULL
GROUP BY ZIP_Code

--Aggregate functions and a CTE is used here to see how much prices increase per bedroom and bathroom. 
--We can see that the biggest price jump occurs from 2 to 3 bedrooms for average home sale price. 

WITH BedAvgPrice AS
(
SELECT BedroomsFormatted, AVG(Price_Sold) as AveragePrice
FROM master.dbo.Wauwatosa_Recent_Home_Sales
WHERE BedroomsFormatted IS NOT NULL 
GROUP BY BedroomsFormatted
)

SELECT BedroomsFormatted, 
		AveragePrice, 
		AveragePrice - COALESCE(LAG(AveragePrice) OVER (ORDER BY AveragePRice), AveragePrice) AS CostIncreasePerBedroom
FROM BedAvgPrice
GROUP BY BedroomsFormatted, AveragePrice
ORDER BY BedroomsFormatted

--Similar Exploratory Analysis using CTEs, but now for bathrooms. 
--Adding another bathroom increases price more than adding another bedroom!

WITH BathAvgPrice AS
(
SELECT BathroomsFormatted, AVG(Price_Sold) as AveragePrice
FROM master.dbo.Wauwatosa_Recent_Home_Sales
WHERE BathroomsFormatted IS NOT NULL 
GROUP BY BathroomsFormatted
)

SELECT BathroomsFormatted, 
		AveragePrice, 
		AveragePrice - COALESCE(LAG(AveragePrice) OVER (ORDER BY AveragePRice), AveragePrice) AS CostIncreasePerBathroom
FROM BathAvgPrice
GROUP BY BathroomsFormatted, AveragePrice
ORDER BY BathroomsFormatted

--A simple look at average home prices by different combinations of Bedroom and Bathrooms

SELECT BedroomsFormatted, BathroomsFormatted, AVG(Price_Sold) as AveragePrice
FROM master.dbo.Wauwatosa_Recent_Home_Sales
WHERE BedroomsFormatted IS NOT NULL AND BathroomsFormatted IS NOT NULL
GROUP BY BedroomsFormatted, BathroomsFormatted
ORDER BY BedroomsFormatted

--Here we classify home sizes using the CASE WHEN clause and categorizing by square footage.
--Our client wants a home with at least 2,000 Sqft but less than 2,500 Sqft.
--We want to pull some comparisons (comps) that are within their price range and have at least 3 bathrooms.
--After our query ran, we made it into a CTE so we could count how many homes that fit this description. We found 10 homes that would fit the client's needs.
--This set of queries can be helpful as it can be easily modified find comps based on price range, desired bedrooms, and desired bathrooms.

SELECT 
	Price_Sold,	
	BedroomsFormatted, 
	BathroomsFormatted, 
	Sqft, 
	CASE	
			WHEN Sqft < 1000 THEN 'Much too small'
			WHEN Sqft <1501 THEN 'Too small'
			WHEN Sqft <2001 THEN 'A little small'
			WHEN Sqft <2501 THEN 'Just right'
			WHEN Sqft <3001 THEN 'Too big'
			ELSE 'Much too big'
			END AS Size_Fit
FROM master.dbo.Wauwatosa_Recent_Home_Sales
WHERE BathroomsFormatted >= 3 AND Price_Sold BETWEEN 400000 AND 500000;

--Make CTE--

WITH Right_Size AS
(
SELECT 
	Price_Sold,	
	BedroomsFormatted, 
	BathroomsFormatted, 
	Sqft, 
	CASE	
			WHEN Sqft < 1000 THEN 'Much too small'
			WHEN Sqft <1501 THEN 'Too small'
			WHEN Sqft <2001 THEN 'A little small'
			WHEN Sqft <2501 THEN 'Just right'
			WHEN Sqft <3001 THEN 'Too big'
			ELSE 'Much too big'
			END AS Size_Fit
FROM master.dbo.Wauwatosa_Recent_Home_Sales
WHERE BathroomsFormatted >= 3 AND Price_Sold BETWEEN 400000 AND 500000
)

SELECT Size_Fit, COUNT(Size_Fit) AS SimilarHomeSold
FROM Right_Size 
GROUP BY Size_fit


--These queries let us see how prices change by year and month, so we can evaluate when prices might be higher or when they might be lower.
--The first query uses a window function to generate monthly average sales prices, partitioning by month.

SELECT 
	YEAR(Date_Sold) AS Yearo_of_Sale, 
	MONTH(Date_Sold) AS Month_of_Sale,  
	AVG(Price_Sold) OVER(PARTITION BY YEAR(Date_Sold), MONTH(Date_Sold)) As Month_Average
FROM master.dbo.Wauwatosa_Recent_Home_Sales
ORDER BY 1, 2 ASC

--The second query generates the highest monthly average and the lowest monthly average for all homes sold using a SELECT statement in the FROM clause.

SELECT 
	MAX(Month_Average) AS Max_Monthly_Average_Price,
	MIN(Month_Average) AS Min_Monthly_Average_Price		
FROM (SELECT AVG(Price_Sold) OVER (PARTITION BY Year (Date_Sold), MONTH(Date_Sold)) AS Month_Average
		FROM master.dbo.Wauwatosa_Recent_Home_Sales) AS Average_Price_By_Month

--Because the Max_Monthly Average Price was very high (> $800,000), we likely have an outlier month (most other months have averages less than $500,000). 
--The lowest average price that was paid in a given month was March of 2021, where the average price to buy a home was around $320,000. 











