SELECT Experiment,
       sum(CASE
               WHEN Group_Type = 'Control' THEN 1
               ELSE 0
           END) AS Control_Group_Size,
       sum(CASE
               WHEN Group_Type = 'Test' THEN 1
               ELSE 0
           END) AS Test_Group_Size
FROM visitor_assignments
GROUP BY Experiment;

