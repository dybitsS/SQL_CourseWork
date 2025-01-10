-- Кол-во товара на складе по категориям 
SELECT cat."Name" AS Category, sum(p."StockQuantity") AS ProductCount
FROM "Categories" cat
JOIN "Products" p USING("CategoryID")
GROUP BY cat."Name";


-- В какой день продаётся больше всего товаров
SELECT 
    TO_CHAR("OrderDate", 'FMDay') AS DayOfWeek, 
    SUM(od."Quantity") AS QuantitySold
FROM "Orders" o 
JOIN "OrderDetails" od USING("OrderID")
JOIN "Products" p USING("ProductID")
JOIN "Categories" c USING("CategoryID")
GROUP BY TO_CHAR("OrderDate", 'FMDay')
ORDER BY 
    CASE 
        WHEN TO_CHAR("OrderDate", 'FMDay') = 'Monday' THEN 1
        WHEN TO_CHAR("OrderDate", 'FMDay') = 'Tuesday' THEN 2
        WHEN TO_CHAR("OrderDate", 'FMDay') = 'Wednesday' THEN 3
        WHEN TO_CHAR("OrderDate", 'FMDay') = 'Thursday' THEN 4
        WHEN TO_CHAR("OrderDate", 'FMDay') = 'Friday' THEN 5
        WHEN TO_CHAR("OrderDate", 'FMDay') = 'Saturday' THEN 6
        WHEN TO_CHAR("OrderDate", 'FMDay') = 'Sunday' THEN 7
    END;


-- Кол-во отмен по странам
SELECT a."Country", COUNT(*) AS "CanceledOrdersCount"
FROM "Orders" o
JOIN "OrderDetails" od USING("OrderID")
JOIN "Clients" c USING("ClientID")
JOIN "Status" s ON o."StatusId" = s."StatusID"
JOIN "Addresses" a ON c."AddressID" = a."AddressID"
WHERE s."Name" = 'Canceled'
GROUP BY a."Country"
ORDER BY "CanceledOrdersCount" DESC;