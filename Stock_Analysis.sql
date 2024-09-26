--STOCK MARKET ANALYSIS WITH ALPHA VANTAGE API

SELECT * FROM DBO.StockData

----------------------------------------------------------------------------------------------
--CALCULATING DAILY RETURNS
WITH DailyReturns AS (
    SELECT dbo.StockData.date, 
           dbo.StockData.[close],
           LAG(dbo.StockData.[close]) OVER (ORDER BY dbo.StockData.date) AS prev_close
    FROM dbo.StockData
)
SELECT date, 
       ([close] - prev_close) / prev_close AS daily_return
FROM DailyReturns;

----------------------------------------------------------------------------------------------------

--FINDING THE MAX CLOSING PRICE
SELECT TOP 1 dbo.StockData.date, dbo.StockData.[close]
FROM StockData 
ORDER BY dbo.StockData.[close] DESC;
------------------------------------------------------------------------------------------------------

--CALCULATING MOVING AVERAGE
SELECT dbo.StockData.date,
       AVG(dbo.StockData.[close]) OVER (ORDER BY date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_avg_5d
FROM StockData;

--------------------------------------------------------------------------------------------------------

--RANKING STOCKS BY VOLUME
SELECT dbo.StockData.date, 
       volume,
       RANK() OVER (ORDER BY volume DESC) AS volume_rank
FROM StockData;

----------------------------------------------------------------------------------------------------------

--IDNETIFY PRICE INCREASE STREAKS
WITH PriceStreaks AS (
    SELECT dbo.StockData.date,
           dbo.StockData.[close],
           LAG(dbo.StockData.[close]) OVER (ORDER BY date) AS prev_close,
           CASE WHEN dbo.StockData.[close] > LAG(dbo.StockData.[close]) OVER (ORDER BY dbo.StockData.date) THEN 1 ELSE 0 END AS is_increasing
    FROM StockData
)
SELECT date,
       SUM(is_increasing) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING) AS increase_streak
FROM PriceStreaks;

-----------------------------------------------------------------------------------------------------------

--CALCULATE CUMULATIVE VOLUME
SELECT date,
       SUM(volume) OVER (ORDER BY dbo.StockData.date) AS cumulative_volume
FROM StockData;

-------------------------------------------------------------------------------------------------------------

--FIND TOP 3 HIGHEST VOLUME DATES
SELECT TOP 3 dbo.StockData.date, volume 
FROM StockData 
ORDER BY volume DESC;

--------------------------------------------------------------------------------------------------------------

--DETERMINE VOLATILITY USING STANDARD DEVIATION
SELECT AVG(dbo.StockData.[close]) AS avg_close,
       STDEV(dbo.StockData.[close]) AS volatility 
FROM StockData;

---------------------------------------------------------------------------------------------------------------

--IDENTIFY DAYS WITH CLOSING PRICE ABOVE AVERAGE
WITH AvgClose AS (
    SELECT AVG(dbo.StockData.[close]) AS avg_close 
    FROM StockData
)
SELECT s.date, s.[close] 
FROM StockData s, AvgClose a 
WHERE s.[close] > a.avg_close;

----------------------------------------------------------------------------------------------------------------------

--CALCULATE PERCENTAGE CHANGE FROM FIRST DAY
WITH FirstDayClose AS (
    SELECT TOP 1 date AS first_date, [close] AS first_close
    FROM dbo.StockData
    ORDER BY date ASC
)
SELECT s.date,
       ((s.[close] - f.first_close) / f.first_close * 100) AS percent_change_from_first_day
FROM dbo.StockData s
CROSS JOIN FirstDayClose f;