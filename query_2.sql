DROP TABLE IF EXISTS [7_day_rolling_avg];

CREATE TABLE [7_day_rolling_avg]
  (
   [date]              VARCHAR(10)
  ,[7_day_rolling_avg] INT
  )
;

-- Group the daily total test results by date
WITH [cte_date]
  ( 
    [date]
   ,[test_results]
  )
AS
  (
   SELECT
     [date]
    ,SUM( [totalTestResultsIncrease] )
   FROM [all-states-history]
   GROUP BY [date]
   )
,
-- Determine the 7 day rolling average for a 36 date period in order to provide a full dataset for the earliest 6 dates
[cte_avg]
  (
    [date]
   ,[test_results_avg]
  ) 
AS
  (
   SELECT
     [date]
    ,AVG( [test_results] ) OVER (
       ORDER BY [date] ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       AS [rolling_avg]
   FROM [cte_date]
   WHERE [date] BETWEEN DATEADD(day, -36, CAST(GETDATE() AS [date] ) ) AND DATEADD(day, -1, CAST(GETDATE() AS [date] ) )
  )

INSERT INTO [7_day_rolling_avg]
  (
   [date]
  ,[7_day_rolling_avg]
  ) 
-- Final query
SELECT
  [date]
 ,SUM([test_results_avg])
FROM [cte_avg]
WHERE [date] BETWEEN DATEADD(day, -30, CAST(GETDATE() AS [date] ) ) AND DATEADD(day, -1, CAST(GETDATE() AS [date] ) )
GROUP BY [date]
ORDER BY [date] DESC
