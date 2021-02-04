DROP TABLE IF EXISTS [state_positive_rate];

CREATE TABLE [state_positive_rate]
  (
   [state]            VARCHAR(2)
  ,[percent_positive] FLOAT
  );

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

SELECT
   [state]
  ,SUM([percent_positive])
FROM [cte_ntile]
WHERE [ntile_] = '5'
GROUP BY 
   [state]
  ,[ntile_]
