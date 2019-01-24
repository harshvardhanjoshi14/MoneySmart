SELECT Page_ID,
       Visit_Date,
       count(*) AS Total_User_Sessions
FROM pageviews
GROUP BY Page_ID,
         Visit_Date;

