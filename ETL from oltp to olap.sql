INSERT INTO DimDates (Date, Year, Month, Day, Week, Quarter)
SELECT DISTINCT 
    o."OrderDate",
    EXTRACT(YEAR FROM o."OrderDate")::int,
    EXTRACT(MONTH FROM o."OrderDate")::int,
    EXTRACT(DAY FROM o."OrderDate")::int,
    EXTRACT(WEEK FROM o."OrderDate")::int,
    CASE 
        WHEN EXTRACT(MONTH FROM o."OrderDate") IN (1, 2, 3) THEN 1
        WHEN EXTRACT(MONTH FROM o."OrderDate") IN (4, 5, 6) THEN 2
        WHEN EXTRACT(MONTH FROM o."OrderDate") IN (7, 8, 9) THEN 3
        WHEN EXTRACT(MONTH FROM o."OrderDate") IN (10, 11, 12) THEN 4
    END AS Quarter
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT DISTINCT "OrderDate" FROM public."Orders"'
) AS o("OrderDate" date)
WHERE NOT EXISTS (
    SELECT 1 
    FROM DimDates dd 
    WHERE dd.Date = o."OrderDate"
)
UNION
SELECT 
    CURRENT_DATE,
    EXTRACT(YEAR FROM CURRENT_DATE)::int,
    EXTRACT(MONTH FROM CURRENT_DATE)::int,
    EXTRACT(DAY FROM CURRENT_DATE)::int,
    EXTRACT(WEEK FROM CURRENT_DATE)::int,
    EXTRACT(QUARTER FROM CURRENT_DATE)::int
WHERE NOT EXISTS (
    SELECT 1 
    FROM DimDates dd 
    WHERE dd.Date = CURRENT_DATE
);

INSERT INTO DimCities (CitySK, CityName)
SELECT DISTINCT "CityID", "CityName"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "CityID", "CityName" FROM public."Cities"'
) AS cities("CityID" int, "CityName" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimCities dc WHERE dc.CityName = cities."CityName");

INSERT INTO DimAddresses (AddressSK, Street, CitySK, PostalCode, Country)
SELECT DISTINCT a."AddressID",
                a."Street", 
                a."CityID", 
                a."PostalCode", 
                a."Country"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "AddressID", "Street", "CityID", "PostalCode", "Country" FROM public."Addresses"'
) AS a("AddressID" int, "Street" varchar, "CityID" int, "PostalCode" varchar, "Country" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimAddresses da WHERE da.Street = a."Street" AND da.PostalCode = a."PostalCode" AND da.Country = a."Country");

INSERT INTO DimCategories (CategorySK, Name)
SELECT DISTINCT "CategoryID", "Name"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "CategoryID", "Name" FROM public."Categories"'
) AS categories("CategoryID" int, "Name" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimCategories dc WHERE dc.Name = categories."Name");

INSERT INTO DimConditions (ConditionSK, Name)
SELECT DISTINCT "ConditionId", "Name"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "ConditionId", "Name" FROM public."Condition"'
) AS conditions("ConditionId" int, "Name" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimConditions dc WHERE dc.Name = conditions."Name");

INSERT INTO DimStatus (StatusSK, Name)
SELECT DISTINCT "StatusID", "Name"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "StatusID", "Name" FROM public."Status"'
) AS status("StatusID" int, "Name" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimStatus ds WHERE ds.Name = status."Name");

INSERT INTO DimPickUp (PickUpSK, Name)
SELECT DISTINCT "PickUpID", "DeliveryType"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "PickUpID", "DeliveryType" FROM public."PickUpOptions"'
) AS pickupoptions("PickUpID" int, "DeliveryType" varchar)
WHERE NOT EXISTS (
    SELECT 1 
    FROM DimPickUp dpo 
    WHERE dpo.Name = pickupoptions."DeliveryType");


WITH updated_products AS (
    SELECT 
        p."ProductID",
    	p."Name", 
    	p."CategoryID", 
    	p."ConditionID", 
   		p."Era", 
   		p."Price",
        (SELECT DatesKey FROM DimDates WHERE Date = CURRENT_DATE) AS StartDateID
	FROM dblink(
    	'dbname=oltp_database user=postgres password=123 host=localhost',
    	'SELECT "ProductID", "Name", "CategoryID", "ConditionID", "Era", "Price" FROM public."Products"'
	) AS p("ProductID" int, "Name" varchar, "CategoryID" int, "ConditionID" int, "Era" varchar, "Price" decimal)
    LEFT JOIN DimProducts dp ON dp.ProductSK = p."ProductID"
    WHERE dp.ProductSK IS NULL OR (dp.IsCurrent AND (TRIM(p."Name") <> TRIM(dp.Name)
        OR TRIM(p."Era") <> TRIM(dp.Era)
        OR p."CategoryID" <> dp.CategorySK
        OR p."ConditionID" <> dp.ConditionSK
		OR p."Price" <> dp.Price))),
update_product AS (
    UPDATE DimProducts
    SET 
        IsCurrent = false,
        EndDateID = (SELECT DatesKey FROM DimDates WHERE Date = CURRENT_DATE)
    WHERE 
        ProductSK IN (SELECT "ProductID" FROM updated_products) AND IsCurrent = true
)
INSERT INTO DimProducts (ProductSK, Name, CategorySK, ConditionSK, Era, Price, IsCurrent, StartDateID)
    SELECT "ProductID", "Name", "CategoryID", "ConditionID", "Era", "Price", true, StartDateID
    FROM updated_products;

WITH updated_customers AS (
    SELECT 
        c."ClientID",
        c."Name",
        c."Email",
        c."PhoneNumber",
        c."AddressID",
        c."Preferences_Category",
        (SELECT DatesKey FROM DimDates WHERE Date = CURRENT_DATE) AS StartDateID
    FROM dblink(
        'dbname=oltp_database user=postgres password=123 host=localhost',
        'SELECT "ClientID", "Name", "Email", "PhoneNumber", "AddressID", "Preferences_Category" FROM public."Clients"'
    ) AS c("ClientID" int, "Name" varchar, "Email" varchar, "PhoneNumber" varchar(20), "AddressID" int, "Preferences_Category" int)
    LEFT JOIN DimClients dc ON dc.ClientSK = c."ClientID"
    WHERE dc.ClientSK IS NULL OR (dc.IsCurrent AND (TRIM(c."Name") <> TRIM(dc.Name)
        OR TRIM(c."PhoneNumber") <> TRIM(dc.PhoneNumber)
        OR c."AddressID" <> dc.AddressSK
        OR c."Preferences_Category" <> dc.PreferencesCategorySK))),
update_customer AS (
    UPDATE DimClients
    SET 
        IsCurrent = false,
        EndDateID = (SELECT DatesKey FROM DimDates WHERE Date = CURRENT_DATE)
    WHERE 
        ClientSK IN (SELECT "ClientID" FROM updated_customers) AND IsCurrent = true
)
INSERT INTO DimClients (ClientSK ,Name, Email, PhoneNumber, AddressSK, PreferencesCategorySK, StartDateID, IsCurrent)
    SELECT "ClientID", "Name", "Email", "PhoneNumber", "AddressID", "Preferences_Category", StartDateID, true
    FROM updated_customers;

INSERT INTO FactSales (DatesKey, ProductSK, ClientSK, StatusSK, Quantity, TotalSalesAmount, PickUpSK)
SELECT 
    dd.DatesKey,
    dp.ProductSK,
    dc.ClientSK,
    ds.StatusSK,
    od."Quantity",
    od."Quantity" * dp.Price AS TotalSalesAmount,
    dpo.PickUpSK
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT o."OrderDate", od."ProductID", od."Quantity", p."Price", o."ClientID", o."StatusId", o."PickUpOptions"
     FROM public."Orders" o
     JOIN public."OrderDetails" od ON o."OrderID" = od."OrderID"
     JOIN public."Products" p ON p."ProductID" = od."ProductID"'
) AS od("OrderDate" date, "ProductID" int, "Quantity" int, "Price" decimal, "ClientID" int, "StatusId" int, "PickUpOptions" int)
JOIN DimProducts dp ON dp.ProductSK = od."ProductID" and dp.IsCurrent
JOIN DimClients dc ON dc.ClientSK = od."ClientID"
JOIN DimStatus ds ON ds.StatusSK = od."StatusId"
JOIN DimDates dd ON dd.Date = od."OrderDate"
JOIN DimPickUp dpo ON dpo.PickUpSK = od."PickUpOptions"
ON CONFLICT (ProductSK, ClientSK, DatesKey) DO UPDATE SET 
    Quantity = EXCLUDED.Quantity,
    TotalSalesAmount = EXCLUDED.TotalSalesAmount,
    StatusSK = EXCLUDED.StatusSK,
    PickUpSK = EXCLUDED.PickUpSK
WHERE 
    FactSales.Quantity <> EXCLUDED.Quantity OR
    FactSales.TotalSalesAmount <> EXCLUDED.TotalSalesAmount OR
    FactSales.StatusSK <> EXCLUDED.StatusSK OR
    FactSales.PickUpSK <> EXCLUDED.PickUpSK;

INSERT INTO FactInventory (ProductSK, DatesKey, StockQuantity)
SELECT 
    (SELECT ProductSK FROM DimProducts dp WHERE dp.Name = p."Name" and dp.IsCurrent),
    (SELECT DatesKey FROM DimDates dd WHERE dd.Date = CURRENT_DATE),
    p."StockQuantity"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "Name", "StockQuantity" FROM public."Products"'
) AS p("Name" varchar, "StockQuantity" int)
ON CONFLICT (DatesKey, ProductSK) DO UPDATE
SET StockQuantity = EXCLUDED.StockQuantity
WHERE FactInventory.StockQuantity <> EXCLUDED.StockQuantity;
