-- DisplayAssortedData.sql
-- SDC250L Project Part 5.2 – Displaying Assorted Data
-- Name: Patrick Gonzalez
-- Student ID: patgon2554

-- Q1. Display the USERID of any users who have not made an order.
SELECT userid FROM userbase
MINUS
SELECT userid FROM orders;

-- Q2. Display the PRODUCTCODE of any products that have no reviews.
SELECT productcode FROM productlist
MINUS
SELECT productcode FROM reviews;

-- Q3. Display all data in the USERBASE table. Show “Adult” for users 18+ and “Minor” otherwise.
SELECT u.*,
       CASE
         WHEN MONTHS_BETWEEN(SYSDATE, u.birthday) / 12 >= 18 THEN 'Adult'
         ELSE 'Minor'
       END AS age_group
FROM userbase u;

-- Q4. Display all data in the PRODUCTLIST table. Show “On Sale” for price <= 20, and “Base Price” otherwise.
SELECT p.*,
       CASE
         WHEN p.price <= 20 THEN 'On Sale'
         ELSE 'Base Price'
       END AS price_group
FROM productlist p;

-- Q5. Display the USERID of any user who has played GAME6 and has a user profile image.
SELECT DISTINCT ul.userid
FROM userlibrary ul
JOIN userprofile up ON up.userid = ul.userid
WHERE ul.productcode = 'GAME6'
  AND up.imagefile IS NOT NULL;

-- Q6. Display PRODUCTCODE from the INTERSECT of WISHLIST and REVIEWS (position 1 or 2; rating 3+).
(SELECT productcode
 FROM wishlist
 WHERE position IN (1, 2))
INTERSECT
(SELECT productcode
 FROM reviews
 WHERE rating >= 3);

-- Q7. Display both users’ USERNAME and BIRTHDAY for users who share the same BIRTHDAY (self-join).
SELECT a.username  AS username_1,
       a.birthday  AS birthday,
       b.username  AS username_2
FROM userbase a
JOIN userbase b
  ON a.birthday = b.birthday
 AND a.userid < b.userid;

-- Q8. Display the Cartesian Product of USERLIBRARY cross joined with WISHLIST.
SELECT *
FROM userlibrary
CROSS JOIN wishlist;

-- Q9. UNION ALL on USERBASE and PRODUCTLIST to generate data on all users and products.
SELECT 'USER' AS record_type,
       TO_CHAR(u.userid) AS id_value,
       u.username AS name_value,
       CAST(NULL AS VARCHAR2(200)) AS detail_value
FROM userbase u
UNION ALL
SELECT 'PRODUCT' AS record_type,
       p.productcode AS id_value,
       p.productname AS name_value,
       TO_CHAR(p.price) AS detail_value
FROM productlist p;

-- Q10. UNION ALL on CHATLOG and USERPROFILE to generate data on user activity.
SELECT 'CHAT' AS activity_type,
       c.senderid AS userid,
       c.content AS activity_detail
FROM chatlog c
UNION ALL
SELECT 'PROFILE' AS activity_type,
       up.userid AS userid,
       up.description AS activity_detail
FROM userprofile up;

-- Q11. Display the USERNAME of all users who have not received an INFRACTION.
SELECT username FROM userbase
MINUS
SELECT u.username
FROM userbase u
JOIN infractions i ON i.userid = u.userid;

-- Q12. Display the TITLE and DESCRIPTION of any COMMUNITYRULES that have not been broken.
SELECT title, description
FROM communityrules
MINUS
SELECT cr.title, cr.description
FROM communityrules cr
JOIN infractions i ON i.rulenum = cr.rulenum;

-- Q13. Display the USERNAME and EMAIL of all users who have received a penalty for their INFRACTION.
SELECT DISTINCT u.username,
       u.email
FROM userbase u
JOIN infractions i ON i.userid = u.userid
WHERE i.penalty IS NOT NULL;

-- Q14. Display dates where an INFRACTION was assigned and a USERSUPPORT ticket was submitted on the same day.
(SELECT TRUNC(dateassigned) AS the_date FROM infractions)
INTERSECT
(SELECT TRUNC(datesubmitted) AS the_date FROM usersupport);

-- Q15. Display every COMMUNITYRULES TITLE and PENALTY.
SELECT DISTINCT cr.title,
       i.penalty
FROM communityrules cr
LEFT JOIN infractions i ON i.rulenum = cr.rulenum;

-- Q16. Display all data in COMMUNITYRULES. Show “Bannable” for severitypoint >= 10, and “Appealable” otherwise.
SELECT cr.*,
       CASE
         WHEN cr.severitypoint >= 10 THEN 'Bannable'
         ELSE 'Appealable'
       END AS rule_status
FROM communityrules cr;

-- Q17. Display all data in USERSUPPORT. Show “High Priority” for tickets not closed and not updated in past week.
SELECT us.*,
       CASE
         WHEN UPPER(us.status) <> 'CLOSED'
              AND TRUNC(NVL(us.dateupdated, us.datesubmitted)) < TRUNC(SYSDATE) - 7
         THEN 'High Priority'
         ELSE 'Normal'
       END AS priority_level
FROM usersupport us;

-- Q18. Display the Cartesian Product of USERSUPPORT cross joined with INFRACTIONS.
SELECT *
FROM usersupport
CROSS JOIN infractions;

-- Q19. Display both TICKETIDs and DATEUPDATED for CLOSED tickets where DATEUPDATED is on the same day (self-join).
SELECT a.ticketid   AS ticketid_1,
       a.dateupdated AS dateupdated,
       b.ticketid   AS ticketid_2
FROM usersupport a
JOIN usersupport b
  ON TRUNC(a.dateupdated) = TRUNC(b.dateupdated)
 AND a.ticketid < b.ticketid
WHERE UPPER(a.status) = 'CLOSED'
  AND UPPER(b.status) = 'CLOSED';

-- Q20. UNION ALL on USERBASE and INFRACTIONS to generate data on user activity.
SELECT 'USER' AS activity_type,
       u.userid AS userid,
       u.username AS activity_detail
FROM userbase u
UNION ALL
SELECT 'INFRACTION' AS activity_type,
       i.userid AS userid,
       'INFRACTION ' || TO_CHAR(i.infractionid) AS activity_detail
FROM infractions i;
