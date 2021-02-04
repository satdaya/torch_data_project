--I utilized the totalTestResults metric, as it captures the testing variations across states.
--Some states measure the total test by each test encounter. Others measure specimens taken. And a third category measures unique individuals.

DROP TABLE IF EXISTS [total_test_results];

CREATE TABLE [total_test_results]
  (
   [total_test_results]  INT
  )

INSERT INTO [total_test_results]
  (
   [total_test_results]
  )

SELECT 
  SUM([totalTestResults]) AS [total_test_results]
FROM [all-states-history]
WHERE [date] = DATEADD(day, -1, CAST(GETDATE() AS [date] ) )
