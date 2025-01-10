-- Кол-во товара на складе по категориям 
SELECT dm.Name AS Category, SUM(fi.stockquantity) as "Stock Quantity" 
FROM FactInventory fi
JOIN Dimproducts USING(productSK)
JOIN DimCategories dm USING(categorySK)
GROUP BY dm.Name

-- В какой день продаётся больше всего товаров
SELECT 
    TO_CHAR(dd.Date, 'FMDay') AS DayOfWeek, 
    SUM(fs.Quantity) AS QuantitySold
FROM FactSales fs
JOIN DimDates dd ON fs.DateSK = dd.DateSK
JOIN DimProducts dp ON fs.ProductSK = dp.ProductSK
JOIN DimCategories dc ON dp.CategorySK = dc.CategorySK
GROUP BY TO_CHAR(dd.Date, 'FMDay')
ORDER BY 
    CASE 
        WHEN TO_CHAR(dd.Date, 'FMDay') = 'Monday' THEN 1
        WHEN TO_CHAR(dd.Date, 'FMDay') = 'Tuesday' THEN 2
        WHEN TO_CHAR(dd.Date, 'FMDay') = 'Wednesday' THEN 3
        WHEN TO_CHAR(dd.Date, 'FMDay') = 'Thursday' THEN 4
        WHEN TO_CHAR(dd.Date, 'FMDay') = 'Friday' THEN 5
        WHEN TO_CHAR(dd.Date, 'FMDay') = 'Saturday' THEN 6
        WHEN TO_CHAR(dd.Date, 'FMDay') = 'Sunday' THEN 7
    END;

-- Кол-во отмен по странам
SELECT da.Country, COUNT(*) AS CanceledOrdersCount
FROM FactSales fs
JOIN DimClients dc ON fs.ClientSK = dc.ClientSK
JOIN DimAddresses da ON dc.AddressSK = da.AddressSK
JOIN DimStatus ds ON fs.StatusSK = ds.StatusSK
WHERE ds.Name = 'Canceled'
GROUP BY da.Country
ORDER BY CanceledOrdersCount DESC;