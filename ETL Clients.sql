DROP TABLE IF EXISTS TempClients;

CREATE TEMP TABLE TempClients (
  ClientsName VARCHAR,
  Email VARCHAR,
  PhoneNumber VARCHAR,
  Address TEXT,
  PreferenceCategory VARCHAR);


COPY TempClients(ClientsName, Email, PhoneNumber, Address, PreferenceCategory)
FROM 'D:\SQL\CourseWorkSQL\Clients.csv' DELIMITER ',' CSV HEADER;

WITH NewCities AS (
  SELECT DISTINCT 
    SPLIT_PART(Address, ',', 2) AS "CityName"
  FROM TempClients
  LEFT JOIN "Cities" ON "Cities"."CityName" = SPLIT_PART(Address, ',', 2)
  WHERE "Cities"."CityID" IS NULL
)
INSERT INTO "Cities" ("CityName")
SELECT "CityName"
FROM NewCities;

WITH NewAddresses AS (
  SELECT DISTINCT 
    SPLIT_PART(Address, ',', 1) AS "Street",
    (SELECT "CityID" FROM "Cities" WHERE "CityName" = SPLIT_PART(Address, ',', 2) LIMIT 1) AS "CityID",
    SPLIT_PART(Address, ',', 3) AS "PostalCode",
    SPLIT_PART(Address, ',', 4) AS "Country"
  FROM TempClients
  LEFT JOIN "Addresses" 
    ON "Addresses"."Street" = SPLIT_PART(Address, ',', 1)
    AND "Addresses"."CityID" = (SELECT "CityID" FROM "Cities" WHERE "CityName" = SPLIT_PART(Address, ',', 2) LIMIT 1)
  WHERE "Addresses"."AddressID" IS NULL
)
INSERT INTO "Addresses" ("Street", "CityID", "PostalCode", "Country")
SELECT "Street", "CityID", "PostalCode", "Country"
FROM NewAddresses;



INSERT INTO "Clients" ("Name", "Email", "PhoneNumber", "AddressID", "Preferences_Category")
SELECT 
  ClientsName AS "Name",
  Email,
  PhoneNumber,
  (SELECT "AddressID" FROM "Addresses" WHERE "Street" = SPLIT_PART(Address, ',', 1) LIMIT 1) AS "AddressID",
  (SELECT "CategoryID" FROM "Categories" WHERE "Name" = PreferenceCategory LIMIT 1) AS "Preferences_Category"
FROM TempClients
WHERE EXISTS (SELECT 1 FROM "Categories" WHERE "Name" = PreferenceCategory)
ON CONFLICT ("Email") DO UPDATE SET
  "Name" = EXCLUDED."Name",
  "PhoneNumber" = EXCLUDED."PhoneNumber",
  "AddressID" = EXCLUDED."AddressID",
  "Preferences_Category" = EXCLUDED."Preferences_Category"
WHERE 
  "Clients"."Name" <> EXCLUDED."Name" OR
  "Clients"."PhoneNumber" <> EXCLUDED."PhoneNumber" OR
  "Clients"."AddressID" <> EXCLUDED."AddressID" OR
  "Clients"."Preferences_Category" <> EXCLUDED."Preferences_Category";

DROP TABLE IF EXISTS TempClients;