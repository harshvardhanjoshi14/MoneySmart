SELECT Experiment, Date, MAX(User_Group_Assignments) AS User_Group_Assignments
FROM
  (SELECT COUNT(*) AS User_Group_Assignments, Date, Experiment
   FROM visitor_assignments
   GROUP BY Date, Experiment)
GROUP BY Experiment;

