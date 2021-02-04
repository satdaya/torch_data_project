/*The positivity rate is an important but imperfect metric due to the reporting discrepancies across states.
Counting unique individuals rather than testing encounters may acccount for the the high positivity
rates in Alabama, Idaho, and South Dakota */

DROP TABLE IF EXISTS [state_positive_rate];

CREATE TABLE [state_positive_rate]
  (
   [state]            VARCHAR(2) PRIMARY KEY
  ,[percent_positive] FLOAT
  );

--Define the positivity rate by state, excluding territories and DC
WITH [cte_percentile]
  (
   [state]
  ,[percent_positive]
  )
AS
 (
  SELECT
     [state]
    ,CASE WHEN SUM([totalTestResultsIncrease]) = 0 
        THEN 0
        ELSE ROUND ( CAST ( SUM([positiveIncrease]) * 100.00 / SUM([totalTestResultsIncrease]) AS FLOAT), 2 )
        END
   FROM [all-states-history]
   WHERE [date] BETWEEN DATEADD(day, -30, CAST(GETDATE() AS [date] ) ) AND DATEADD(day, -1, CAST(GETDATE() AS [date] ) )
     AND [state] NOT IN ('DC', 'AS', 'VI', 'PR', 'MP', 'GU')
   GROUP BY [state]
 )
,
-- break the 50 states into quintiles
[cte_ntile]
  (
    [state]
   ,[percent_positive]
   ,[ntile_]
  )
AS
 (
   SELECT 
     [state]
    ,SUM([percent_positive])
    ,NTILE(5) OVER
       (ORDER BY SUM([percent_positive]))
   FROM [cte_percentile]
   GROUP BY [state]
  )

INSERT INTO [state_positive_rate]
  (
   [state]
  ,[percent_positive] 
  ) 
-- Final query. Showing only the top quintile.
SELECT
   [state]
  ,SUM([percent_positive])
FROM [cte_ntile]
WHERE [ntile_] = '5'
GROUP BY 
   [state]
  ,[ntile_]
