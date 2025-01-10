INSERT INTO DimDates (Date, Year, Month, Day, Week, Quarter)
SELECT DISTINCT o."OrderDate",
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
    'SELECT DISTINCT "OrderDate" FROM public."Orders"')
AS o("OrderDate" date)
WHERE NOT EXISTS (SELECT 1 FROM DimDates dd WHERE dd.Date = o."OrderDate");

INSERT INTO DimCities (CitySK,CityName)
SELECT DISTINCT "CityID","Name"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "CityID", "CityName" FROM public."Cities"')
	as cities("CityID" int, "Name" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimCities dc WHERE dc.CityName = "Name");

INSERT INTO DimAddresses (AddressSK,Street, CitySK, PostalCode, Country)
SELECT DISTINCT a."AddressID",
                a."Street", 
                a."CityID", 
                a."PostalCode", 
                a."Country"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "AddressID", "Street", "CityID", "PostalCode", "Country" FROM public."Addresses"')
AS a("AddressID" int, "Street" varchar, "CityID" int, "PostalCode" varchar, "Country" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimAddresses da WHERE da.Street = a."Street" AND da.PostalCode = a."PostalCode" and da.Country = a."Country");

INSERT INTO DimCategories (CategorySK,Name)
SELECT DISTINCT "CategoryID","Name"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "CategoryID", "Name" FROM public."Categories"')
AS categories("CategoryID" int, "Name" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimCategories dc WHERE dc.Name = "Name");

INSERT INTO DimConditions (ConditionSK,Name)
SELECT DISTINCT "ConditionId","Name"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "ConditionId", "Name" FROM public."Condition"')
AS conditions("ConditionId" int, "Name" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimConditions dc WHERE dc.Name = "Name");

INSERT INTO DimStatus (StatusSK,Name)
SELECT DISTINCT "StatusID","Name"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "StatusID", "Name" FROM public."Status"')
AS status("StatusID" int, "Name" varchar)
WHERE NOT EXISTS (SELECT 1 FROM DimStatus ds WHERE ds.Name = "Name");

INSERT INTO DimPickUp (PickUpSK,Name)
SELECT DISTINCT "PickUpID","DeliveryType"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "PickUpID", "DeliveryType" FROM public."PickUpOptions"')
AS pickupoptions("PickUpID" int, "DeliveryType" varchar)
WHERE NOT EXISTS (
    SELECT 1 
    FROM DimPickUp dpo 
    WHERE dpo.Name = pickupoptions."DeliveryType");


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM DimDates WHERE Date = CURRENT_DATE) THEN
        INSERT INTO DimDates (Date, Year, Month, Day, Week, Quarter)
        VALUES (
            CURRENT_DATE,
            EXTRACT(YEAR FROM CURRENT_DATE)::int,
            EXTRACT(MONTH FROM CURRENT_DATE)::int,
            EXTRACT(DAY FROM CURRENT_DATE)::int,
            EXTRACT(WEEK FROM CURRENT_DATE)::int,
            EXTRACT(QUARTER FROM CURRENT_DATE)::int
        );
    END IF;
END $$;

INSERT INTO DimProducts (ProductSK,Name, CategorySK, ConditionSK, Era, Price, IsCurrent, StartDateID)
SELECT DISTINCT
	p."ProductID",
    p."Name", 
    p."CategoryID", 
    p."ConditionID", 
    p."Era", 
    p."Price", 
    TRUE, 
    (SELECT datesk FROM dimdates WHERE date = CURRENT_DATE)
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "ProductID", "Name", "CategoryID", "ConditionID", "Era", "Price" FROM public."Products"'
) AS p("ProductID" int, "Name" varchar, "CategoryID" int, "ConditionID" int, "Era" varchar, "Price" decimal)
JOIN DimCategories c ON c.CategorySK = p."CategoryID"
JOIN DimConditions co ON co.ConditionSK = p."ConditionID"
ON CONFLICT (Name) DO UPDATE SET
    CategorySK = EXCLUDED.CategorySK,
    ConditionSK = EXCLUDED.ConditionSK,
    Era = EXCLUDED.Era,
    Price = EXCLUDED.Price,
    IsCurrent = EXCLUDED.IsCurrent,
    StartDateID = EXCLUDED.StartDateID
WHERE 
    DimProducts.CategorySK <> EXCLUDED.CategorySK OR
    DimProducts.ConditionSK <> EXCLUDED.ConditionSK OR
    DimProducts.Era <> EXCLUDED.Era OR
    DimProducts.Price <> EXCLUDED.Price OR
    DimProducts.IsCurrent <> EXCLUDED.IsCurrent OR
    DimProducts.StartDateID <> EXCLUDED.StartDateID;

INSERT INTO DimClients (ClientSK,Name, Email, PhoneNumber, AddressSK, PreferencesCategorySK, IsCurrent, StartDateID)
SELECT DISTINCT 
	c."ClientID",
    c."Name", 
    c."Email", 
    c."PhoneNumber", 
    C."AddressID", 
    c."Preferences_Category", 
    TRUE, 
    (SELECT datesk FROM dimdates WHERE date = CURRENT_DATE)
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "ClientID", "Name", "Email", "PhoneNumber", "AddressID", "Preferences_Category" FROM public."Clients"'
) AS c("ClientID" int, "Name" varchar, "Email" varchar, "PhoneNumber" varchar, "AddressID" int, "Preferences_Category" int)
ON CONFLICT (Email) DO UPDATE SET
    Name = EXCLUDED.Name,
    PhoneNumber = EXCLUDED.PhoneNumber,
    AddressSK = EXCLUDED.AddressSK,
    PreferencesCategorySK = EXCLUDED.PreferencesCategorySK,
    IsCurrent = EXCLUDED.IsCurrent,
    StartDateID = EXCLUDED.StartDateID
WHERE 
    DimClients.Name <> EXCLUDED.Name OR
    DimClients.PhoneNumber <> EXCLUDED.PhoneNumber OR
    DimClients.AddressSK <> EXCLUDED.AddressSK OR
    DimClients.PreferencesCategorySK <> EXCLUDED.PreferencesCategorySK OR
    DimClients.IsCurrent <> EXCLUDED.IsCurrent OR
    DimClients.StartDateID <> EXCLUDED.StartDateID;

INSERT INTO FactSales (DateSK, ProductSK, ClientSK, StatusSK, Quantity, TotalSalesAmount, PickUpSK)
SELECT 
    dd.DateSK,
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
     JOIN public."Products" p ON p."ProductID" = od."ProductID"')
AS od("OrderDate" date, "ProductID" int, "Quantity" int, "Price" decimal, "ClientID" int, "StatusId" int, "PickUpOptions" int)
JOIN DimProducts dp ON dp.ProductSK = od."ProductID"
JOIN DimClients dc ON dc.ClientSK = od."ClientID"
JOIN DimStatus ds ON ds.StatusSK = od."StatusId"
JOIN DimDates dd ON dd.Date = od."OrderDate"
JOIN DimPickUp dpo ON dpo.PickUpSK = od."PickUpOptions"
ON CONFLICT (ProductSK, ClientSK, DateSK) DO UPDATE SET 
    Quantity = EXCLUDED.Quantity,
    TotalSalesAmount = EXCLUDED.TotalSalesAmount,
    StatusSK = EXCLUDED.StatusSK,
    PickUpSK = EXCLUDED.PickUpSK
WHERE 
    FactSales.Quantity <> EXCLUDED.Quantity OR
    FactSales.TotalSalesAmount <> EXCLUDED.TotalSalesAmount OR
    FactSales.StatusSK <> EXCLUDED.StatusSK OR
    FactSales.PickUpSK <> EXCLUDED.PickUpSK;

INSERT INTO FactInventory (ProductSK, DateSK, StockQuantity)
SELECT 
    (SELECT ProductSK from DimProducts d where d.Name = "Name"),
    (SELECT datesk FROM dimdates WHERE date = CURRENT_DATE),
    p."StockQuantity"
FROM dblink(
    'dbname=oltp_database user=postgres password=123 host=localhost',
    'SELECT "Name", "StockQuantity" FROM "Products"'
) AS p("Name" varchar, "StockQuantity" int)
ON CONFLICT (DateSK, ProductSK) DO UPDATE
SET StockQuantity = EXCLUDED.StockQuantity
WHERE FactInventory.StockQuantity <> EXCLUDED.StockQuantity;