DROP TABLE IF EXISTS "temp_products";

CREATE TEMP TABLE "temp_products" (
    "Name" varchar,
    "Description" text,
    "Price" decimal,
    "CategoryName" varchar,
    "ConditionName" varchar,
    "Era" varchar,
    "StockQuantity" int
);

COPY "temp_products" ("Name", "Description", "Price", "CategoryName", "ConditionName", "Era", "StockQuantity")
FROM 'D:\SQL\CourseWorkSQL/Goods.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO "Categories" ("Name")
SELECT DISTINCT "CategoryName"
FROM "temp_products"
WHERE "CategoryName" NOT IN (SELECT "Name" FROM "Categories");

INSERT INTO "Condition" ("Name")
SELECT DISTINCT "ConditionName"
FROM "temp_products"
WHERE "ConditionName" NOT IN (SELECT "Name" FROM "Condition");

INSERT INTO "Products" ("Name", "Description", "Price", "CategoryID", "ConditionID", "Era", "StockQuantity")
SELECT 
    temp."Name",
    temp."Description",
    temp."Price",
    cat."CategoryID",
    cond."ConditionId",
    temp."Era",
    temp."StockQuantity"
FROM "temp_products" temp
JOIN "Categories" cat ON temp."CategoryName" = cat."Name"
JOIN "Condition" cond ON temp."ConditionName" = cond."Name"
ON CONFLICT ("Name") DO UPDATE
SET 
    "Description" = EXCLUDED."Description",
    "Price" = EXCLUDED."Price",
    "CategoryID" = EXCLUDED."CategoryID",
    "ConditionID" = EXCLUDED."ConditionID",
    "Era" = EXCLUDED."Era",
    "StockQuantity" = EXCLUDED."StockQuantity"
WHERE EXCLUDED."Description" IS DISTINCT FROM "Products"."Description"
   OR EXCLUDED."Price" IS DISTINCT FROM "Products"."Price"
   OR EXCLUDED."CategoryID" IS DISTINCT FROM "Products"."CategoryID"
   OR EXCLUDED."ConditionID" IS DISTINCT FROM "Products"."ConditionID"
   OR EXCLUDED."Era" IS DISTINCT FROM "Products"."Era"
   OR EXCLUDED."StockQuantity" IS DISTINCT FROM "Products"."StockQuantity";

DROP TABLE IF EXISTS "temp_products";