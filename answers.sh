#!/usr/bin/env bash

printf "\nDisplaying results for Question 1\n"
sqlite3 -header -column exercise1/pageviews ".read exercise1/exercise_1.sql"


printf "\nDisplaying results for Question 2\n"
printf "\nNote: Haven't added the required filters here since it was not returning any output"
printf "\nNote: The filters are present in the SQL script\n"
sqlite3 -header -column exercise2/orders ".read exercise2/exercise_2.sql"


printf "\nLoading data from logs for Question 3\n"
python exercise3/log_loader.py
printf "Log data loaded, created db 'lighthouse_logs'\n"

printf "\nCarrying out query A\n"
sqlite3 -header -column exercise3/lighthouse_logs ".read exercise3/exercise_3_a.sql"

printf "\nCarrying out query B\n"
sqlite3 -header -column exercise3/lighthouse_logs ".read exercise3/exercise_3_b.sql"

rm exercise3/lighthouse_logs
