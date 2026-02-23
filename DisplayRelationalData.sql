--------------------------------------------------
-- Q1: Display every USERNAME and the lowest RATING they have left in a review.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.username,
    MIN(r.rating) AS lowest_rating
FROM userbase u
LEFT JOIN reviews r
    ON r.userid = u.userid
GROUP BY u.username
ORDER BY u.username;


--------------------------------------------------
-- Q2: Display every user’s EMAIL, QUESTION, and ANSWER.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.email,
    sq.question,
    sq.answer
FROM userbase u
JOIN securityquestion sq
    ON sq.userid = u.userid
ORDER BY u.email;


--------------------------------------------------
-- Q3: Display the FIRSTNAME, EMAIL, and WALLETFUNDS of every user that does not have a WISHLIST.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.firstname,
    u.email,
    u.walletfunds
FROM userbase u
LEFT JOIN wishlist w
    ON w.userid = u.userid
WHERE w.userid IS NULL
ORDER BY u.firstname, u.email;


--------------------------------------------------
-- Q4: Display every USERNAME and number of products they have ordered.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.username,
    COUNT(o.productcode) AS products_ordered
FROM userbase u
LEFT JOIN orders o
    ON o.userid = u.userid
GROUP BY u.username
ORDER BY u.username;


--------------------------------------------------
-- Q5: Display the age of any user who has ordered a product within the last 6 months.
--------------------------------------------------
-- Patrick Gonzalez
SELECT DISTINCT
    TRUNC(MONTHS_BETWEEN(SYSDATE, u.birthday) / 12) AS age_years
FROM userbase u
JOIN orders o
    ON o.userid = u.userid
WHERE o.purchasedate >= ADD_MONTHS(TRUNC(SYSDATE), -6)
ORDER BY age_years;


--------------------------------------------------
-- Q6: Display the USERNAME and BIRTHDAY of the user who has the highest friend count.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.username,
    u.birthday
FROM userbase u
JOIN (
    SELECT
        f.userid,
        COUNT(*) AS friend_count
    FROM friendslist f
    GROUP BY f.userid
    ORDER BY friend_count DESC
    FETCH FIRST 1 ROWS ONLY
) fc
    ON fc.userid = u.userid;


--------------------------------------------------
-- Q7: Display the PRODUCTNAME, RELEASEDATE, PRICE, and DESCRIPTION for any product found in the WISHLIST table.
--------------------------------------------------
-- Patrick Gonzalez
SELECT DISTINCT
    p.productname,
    p.releasedate,
    p.price,
    p.description
FROM wishlist w
JOIN productlist p
    ON p.productcode = w.productcode
ORDER BY p.productname;


--------------------------------------------------
-- Q8: Display the PRODUCTNAME, highest RATING, and number of reviews for each product in the REVIEWS table.
--     Order the results in descending order of the RATING.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    p.productname,
    MAX(r.rating) AS highest_rating,
    COUNT(*) AS review_count
FROM reviews r
JOIN productlist p
    ON p.productcode = r.productcode
GROUP BY p.productname
ORDER BY MAX(r.rating) DESC, p.productname;


--------------------------------------------------
-- Q9: Create a view that displays the PRODUCTNAME, GENRE, and RATING for every product with a 5 or a 1 RATING.
--     Order the results in ascending order of the RATING.
--------------------------------------------------
-- Patrick Gonzalez
CREATE OR REPLACE VIEW vg_q9_extreme_ratings AS
SELECT
    p.productname,
    p.genre,
    r.rating
FROM reviews r
JOIN productlist p
    ON p.productcode = r.productcode
WHERE r.rating IN (1, 5)
ORDER BY r.rating ASC, p.productname;


--------------------------------------------------
-- Q10: Display the count of products ordered, grouped by GENRE.
--      Order the results in alphabetical order of GENRE.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    p.genre,
    COUNT(*) AS products_ordered
FROM orders o
JOIN productlist p
    ON p.productcode = o.productcode
GROUP BY p.genre
ORDER BY p.genre;


--------------------------------------------------
-- Q11: Create a view that displays each PUBLISHER, the average PRICE, and the sum of HOURSPLAYED for their products.
--------------------------------------------------
-- Patrick Gonzalez
CREATE OR REPLACE VIEW vg_q11_publisher_summary AS
SELECT
    p.publisher,
    AVG(p.price) AS avg_price,
    SUM(p.hoursplayed) AS total_hoursplayed
FROM productlist p
GROUP BY p.publisher;


--------------------------------------------------
-- Q12: Display the sum of money spent on products and their corresponding PUBLISHER, from the ORDERS table.
--      Order the results in descending order of the sum of money spent.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    p.publisher,
    SUM(o.price) AS total_spent
FROM orders o
JOIN productlist p
    ON p.productcode = o.productcode
GROUP BY p.publisher
ORDER BY total_spent DESC;


--------------------------------------------------
-- Q13: Display the TICKETID, USERNAME, EMAIL, and ISSUE only for tickets with a STATUS of
--      ‘NEW’ or ‘IN PROGRESS’, sorted by the latest DATEUPDATED.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    us.ticketid,
    u.username,
    us.email,
    us.issue
FROM usersupport us
LEFT JOIN userbase u
    ON LOWER(u.email) = LOWER(us.email)
WHERE us.status IN ('NEW', 'IN PROGRESS')
ORDER BY us.dateupdated DESC;


--------------------------------------------------
-- Q14: Display the USERNAME and count of TICKETID that users have submitted for user support.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.username,
    COUNT(us.ticketid) AS ticket_count
FROM userbase u
LEFT JOIN usersupport us
    ON LOWER(us.email) = LOWER(u.email)
GROUP BY u.username
ORDER BY u.username;


--------------------------------------------------
-- Q15: Display the USERID and EMAIL of any user who has submitted a support ticket that used their
--      FIRSTNAME, LASTNAME, or combination of the two in their EMAIL address.
--------------------------------------------------
-- Patrick Gonzalez
SELECT DISTINCT
    u.userid,
    us.email
FROM userbase u
JOIN usersupport us
    ON LOWER(us.email) = LOWER(u.email)
WHERE LOWER(us.email) LIKE '%' || LOWER(u.firstname) || '%'
   OR LOWER(us.email) LIKE '%' || LOWER(u.lastname) || '%'
   OR LOWER(us.email) LIKE '%' || LOWER(u.firstname) || LOWER(u.lastname) || '%'
   OR LOWER(us.email) LIKE '%' || LOWER(u.lastname) || LOWER(u.firstname) || '%'
ORDER BY u.userid;


--------------------------------------------------
-- Q16: Display the EMAIL address of any user who has a ‘NEW’ or ‘IN PROGRESS’ support ticket STATUS,
--      where the EMAIL is not currently saved in the USERBASE table.
--------------------------------------------------
-- Patrick Gonzalez
SELECT DISTINCT
    us.email
FROM usersupport us
WHERE us.status IN ('NEW', 'IN PROGRESS')
  AND NOT EXISTS (
      SELECT 1
      FROM userbase u
      WHERE LOWER(u.email) = LOWER(us.email)
  )
ORDER BY us.email;


--------------------------------------------------
-- Q17: Display the TICKETID, FIRSTNAME, LASTNAME, and USERNAME of any user whose USERNAME is mentioned in the ISSUE.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    us.ticketid,
    u.firstname,
    u.lastname,
    u.username
FROM usersupport us
JOIN userbase u
    ON LOWER(us.issue) LIKE '%' || LOWER(u.username) || '%'
ORDER BY us.ticketid;


--------------------------------------------------
-- Q18: Display the USERNAME and PASSWORD associated with the EMAIL address provided in the support tickets.
--------------------------------------------------
-- Patrick Gonzalez
SELECT DISTINCT
    u.username,
    u.password
FROM usersupport us
JOIN userbase u
    ON LOWER(u.email) = LOWER(us.email)
ORDER BY u.username;


--------------------------------------------------
-- Q19: Create a view that displays the USERNAME, DATEASSIGNED, and PENALTY for any user whose PENALTY is not null
--      and the infraction was assigned within the last month.
--------------------------------------------------
-- Patrick Gonzalez
CREATE OR REPLACE VIEW vg_q19_recent_penalties AS
SELECT
    u.username,
    i.dateassigned,
    i.penalty
FROM infractions i
JOIN userbase u
    ON u.userid = i.userid
WHERE i.penalty IS NOT NULL
  AND i.dateassigned >= ADD_MONTHS(TRUNC(SYSDATE), -1);


--------------------------------------------------
-- Q20: Display the USERNAME and EMAIL of any user who is at least 18 years old and has not received an infraction
--      within the last 4 months.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.username,
    u.email
FROM userbase u
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, u.birthday) / 12) >= 18
  AND NOT EXISTS (
      SELECT 1
      FROM infractions i
      WHERE i.userid = u.userid
        AND i.dateassigned >= ADD_MONTHS(TRUNC(SYSDATE), -4)
  )
ORDER BY u.username;


--------------------------------------------------
-- Q21: Display the USERNAME, DATEASSIGNED, and full guideline name (RULENUM and TITLE with a blank space inbetween)
--      for any user who has violated the community rules.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.username,
    i.dateassigned,
    i.rulenum || ' ' || cr.title AS guideline
FROM infractions i
JOIN userbase u
    ON u.userid = i.userid
JOIN communityrules cr
    ON cr.rulenum = i.rulenum
ORDER BY i.dateassigned DESC, u.username;


--------------------------------------------------
-- Q22: Display the USERID, USERNAME, EMAIL, and sum of all SEVERITYPOINTS each user has received.
-- NOTE: Your INFRACTIONS table does NOT contain numeric severity points, so we total the only measurable value:
--       number of infractions per user (counts as "total severity/penalty points" for this dataset).
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.userid,
    u.username,
    u.email,
    COUNT(i.infractionid) AS total_severitypoints
FROM userbase u
LEFT JOIN infractions i
    ON u.userid = i.userid
GROUP BY u.userid, u.username, u.email
ORDER BY total_severitypoints DESC;


--------------------------------------------------
-- Q23: Display the TITLE, DESCRIPTION, and PENALTY for all infractions assigned.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    cr.title,
    cr.description,
    i.penalty
FROM infractions i
JOIN communityrules cr
    ON cr.rulenum = i.rulenum
ORDER BY cr.title;


--------------------------------------------------
-- Q24: Display the USERNAME and count of infractions for users who have violated the community rules at least 15 times.
--------------------------------------------------
-- Patrick Gonzalez
SELECT
    u.username,
    COUNT(i.infractionid) AS infraction_count
FROM infractions i
JOIN userbase u
    ON u.userid = i.userid
GROUP BY u.username
HAVING COUNT(i.infractionid) >= 15
ORDER BY infraction_count DESC, u.username;