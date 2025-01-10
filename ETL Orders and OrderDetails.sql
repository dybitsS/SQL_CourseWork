DROP TABLE IF EXISTS  "temp_products";

CREATE TEMP TABLE "temp_products" (
    "Customer" varchar,
    "Product" varchar,
    "Quantity" int,
    "PickUpOption" varchar,
    "Status" varchar,
	"OrderDate" date
);

COPY "temp_products" ("Customer", "Product", "Quantity", "PickUpOption", "Status","OrderDate")
FROM 'D:\SQL\CourseWorkSQL/orders.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO "PickUpOptions" ("DeliveryType")
SELECT DISTINCT "PickUpOption"
FROM "temp_products"
WHERE "PickUpOption" NOT IN (SELECT "DeliveryType" FROM "PickUpOptions");

INSERT INTO "Status" ("Name")
SELECT DISTINCT "Status"
FROM "temp_products"
WHERE "Status" NOT IN (SELECT "Name" FROM "Status");

INSERT INTO "Orders" ("ClientID", "OrderDate", "PickUpOptions", "StatusId")
SELECT 
  (SELECT "ClientID" FROM "Clients" WHERE "Name" = "Customer" LIMIT 1),
  "OrderDate",
  (SELECT "PickUpID" FROM "PickUpOptions" WHERE "DeliveryType" = "PickUpOption" LIMIT 1),
  (SELECT "StatusID" FROM "Status" WHERE "Name" = "Status" LIMIT 1)
FROM temp_products
ON CONFLICT ("ClientID", "OrderDate") DO UPDATE SET
  "OrderDate" = EXCLUDED."OrderDate",
  "PickUpOptions" = EXCLUDED."PickUpOptions",
  "StatusId" = EXCLUDED."StatusId"
WHERE 
  "Orders"."OrderDate" <> EXCLUDED."OrderDate" OR
  "Orders"."PickUpOptions" <> EXCLUDED."PickUpOptions" OR
  "Orders"."StatusId" <> EXCLUDED."StatusId";

INSERT INTO "OrderDetails" ("OrderID", "ProductID", "Quantity", "TotalAmount")
SELECT 
    o."OrderID",
    p."ProductID",
    t."Quantity",
    p."Price" * t."Quantity" AS "TotalAmount"
FROM "temp_products" t
JOIN "Clients" c ON c."Name" = t."Customer"
JOIN "Orders" o using("OrderDate")
JOIN "Products" p ON p."Name" = t."Product"
ON CONFLICT ("OrderID", "ProductID") DO UPDATE 
SET
    "Quantity" = EXCLUDED."Quantity",
    "TotalAmount" = EXCLUDED."TotalAmount"
WHERE 
    "OrderDetails"."Quantity" <> EXCLUDED."Quantity" OR
    "OrderDetails"."TotalAmount" <> EXCLUDED."TotalAmount";

DROP TABLE IF EXISTS  "temp_products";