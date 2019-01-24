-- Formulas
-- OrdersForA = No. of distinct orders with ProductA
-- OrdersForB = No. of distinct orders with ProductB
-- OrdersForAB = No. of distinct orders for ProductA and ProductB
-- TotalOrders = Distinct OrderIDs for the top_ten_products
-- SupportA = OrdersForA / TotalOrders
-- SupportB = OrdersForB / TotalOrders
-- Support = OrdersForAB / TotalOrders
-- Confidence = OrdersForAB / OrdersForA
-- LiftRation = Confidence / SupportB

CREATE TEMP TABLE top_ten_products AS
SELECT ProductID,
       COUNT(DISTINCT OrderID) AS NOrders
FROM orders
GROUP BY ProductID
ORDER BY NOrders DESC
LIMIT 10;


CREATE TEMP TABLE orders_with_bestsellers AS
SELECT OrderID
FROM orders
INNER JOIN top_ten_products ON orders.ProductID = top_ten_products.ProductID;


CREATE TEMP TABLE order_counts AS
SELECT ProductID,
       COUNT(DISTINCT OrderID) AS NOrders,

  (SELECT COUNT(DISTINCT OrderID)
   FROM orders_with_bestsellers) AS TotalOrders
FROM orders
WHERE orders.OrderID IN
    (SELECT DISTINCT OrderID
     FROM orders_with_bestsellers)
GROUP BY ProductID;


SELECT ProductA,
       ProductB,
       COUNT (DISTINCT OrderID) AS Occurences,
             round((COUNT (DISTINCT OrderID) * 1.0 / t1.TotalOrders), 3) AS Support,
             round((COUNT (DISTINCT OrderID) * 1.0 / t1.NOrders), 3) AS Confidence,
             round(((COUNT (DISTINCT OrderID) * 1.0 / t1.NOrders) / (t2.NOrders * 1.0 / t2.TotalOrders)), 3) AS LiftRatio
FROM
  (SELECT a.OrderID,
          a.ProductID AS ProductA,
          b.ProductID AS ProductB,
          b.OrderID
   FROM orders AS a,
        orders AS b
   WHERE a.OrderID = b.OrderID
     AND a.ProductID <> b.ProductID
     AND a.ProductID IN
       (SELECT DISTINCT ProductID
        FROM top_ten_products))
LEFT JOIN order_counts AS t1 ON ProductA = t1.ProductID
LEFT JOIN order_counts AS t2 ON ProductB = t2.ProductID
GROUP BY ProductA,
         ProductB;

-- HAVING Support >= 0.2
-- AND Confidence >= 0.6
-- AND LiftRatio > 1;
