--3. A)Find all players in the database who played at Vanderbilt University.  B)Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

--A
SELECT DISTINCT playerid, schoolname, namefirst || ' ' || namelast AS full_name, SUM (salary)::numeric::money AS total_salary
FROM collegeplaying
	JOIN schools USING (schoolid)
	JOIN people USING (playerid)
	LEFT JOIN salaries USING (playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY playerid, schoolname, full_name
ORDER BY total_salary DESC NULLS LAST;

--4. A)Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
-- B) Determine the number of putouts made by each of these three groups in 2016.
SELECT SUM(PO),
	CASE WHEN pos = 'OF' THEN 'Outfield'
 		 WHEN pos IN ('P','C') THEN 'Battery'
	  	 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'	
END AS field_pos	  
FROM  fielding
WHERE yearid = 2016
GROUP BY field_pos

--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
SELECT 
	 ROUND(SUM(so)::numeric / SUM(g), 2) AS so_avg
	,ROUND(SUM(hr)::numeric / SUM(g), 2) AS hr_avg
	,(yearid / 10) * 10 AS decade
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

--6.Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. 
--(A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT namefirst||' '||namelast AS full_name, SUM(sb)+SUM(cs)AS steal_attempts, ROUND(SUM(sb::numeric)/(SUM(sb::numeric)+SUM(cs::numeric))*100,0) AS steal_percentage
FROM batting
	INNER JOIN people USING (playerid)
WHERE yearid = '2016'
GROUP BY playerid,full_name
	HAVING SUM(sb)+SUM(cs) >=20
ORDER BY steal_percentage DESC;

--8.Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
--(where average attendance is defined as total attendance divided by number of games). 
--Only consider parks where there were at least 10 games played. 
--Report the park name, team name, and average attendance. 
--Repeat for the lowest 5 average attendance.

-- SELECT teams.name, SUM(h.attendance)/SUM(games) AS avg_stadium_attendance, SUM(teams.attendance)/SUM(teams.g) AS avg_team_attendance
-- FROM homegames h
-- 	JOIN parks USING (park)
-- 	JOIN teams ON teams.teamid = h.team
-- WHERE year = 2016
-- GROUP BY teams.name
-- 	HAVING SUM(games)>= 10 AND g >= 10
-- ORDER BY 

(SELECT parks.park_name, team, SUM(attendance)/SUM(games) AS avg_stadium_attendance
FROM homegames
	JOIN parks ON homegames.park = parks.park
WHERE year = 2016 AND games >= 10
GROUP BY parks.park_name, team
ORDER BY avg_stadium_attendance DESC 
LIMIT 5)

UNION ALL

(SELECT parks.park_name, team, SUM(attendance)/SUM(games) AS avg_stadium_attendance
FROM homegames
	JOIN parks ON homegames.park = parks.park
WHERE year = 2016 AND games >= 10
GROUP BY parks.park_name, team
ORDER BY avg_stadium_attendance ASC 
LIMIT 5)

--9.Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
--Give their full name and the teams that they were managing when they won the award.

SELECT playerid, namefirst ||' '|| namelast, name, lgid
FROM awardsmanagers
	JOIN people USING (playerid)
	JOIN teams USING (yearid, lgid)
WHERE awardid = 'TSN Manager of the Year'
