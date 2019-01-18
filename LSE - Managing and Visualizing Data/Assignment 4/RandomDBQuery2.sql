SELECT *
FROM Owners

JOIN (SELECT ownerID, count(*)
FROM Cats
GROUP BY ownerID HAVING count(*) >1) as a

ON a.ownerID = Owners.ownerID ;


