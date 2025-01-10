DROP TABLE IF EXISTS 
  "OrderDetails", 
  "Orders", 
  "PickUpOptions", 
  "Status", 
  "Clients", 
  "Addresses", 
  "Cities", 
  "Products", 
  "Categories", 
  "Condition" CASCADE;
  
CREATE EXTENSION IF NOT EXISTS dblink;

CREATE TABLE "Clients" (
  "ClientID" serial PRIMARY KEY,
  "Name" varchar NOT NULL,
  "Email" varchar unique NOT NULL,
  "PhoneNumber" varchar NOT NULL,
  "AddressID" int NOT NULL,
  "Preferences_Category" int
);

CREATE TABLE "Addresses" (
  "AddressID" serial PRIMARY KEY,
  "Street" varchar NOT NULL,
  "CityID" int NOT NULL,
  "PostalCode" varchar NOT NULL,
  "Country" varchar NOT NULL
);

CREATE TABLE "Cities" (
  "CityID" serial PRIMARY KEY,
  "CityName" varchar NOT NULL
);

CREATE TABLE "Products" (
  "ProductID" serial PRIMARY KEY,
  "Name" varchar unique NOT NULL,
  "Description" text NOT NULL,
  "Price" DECIMAL(12, 2) NOT NULL,
  "CategoryID" int NOT NULL,
  "ConditionID" int NOT NULL,
  "Era" varchar,
  "StockQuantity" int NOT NULL
);

CREATE TABLE "Condition" (
  "ConditionId" serial PRIMARY KEY,
  "Name" varchar NOT NULL
);

CREATE TABLE "Categories" (
  "CategoryID" serial PRIMARY KEY,
  "Name" varchar NOT NULL
);

CREATE TABLE "Orders" (
  "OrderID" serial PRIMARY KEY,
  "ClientID" int NOT NULL,
  "OrderDate" date unique NOT NULL,
  "PickUpOptions" int NOT NULL,
  "StatusId" int NOT NULL,
   UNIQUE ("ClientID", "OrderDate")
);

CREATE TABLE "Status" (
  "StatusID" serial PRIMARY KEY,
  "Name" varchar NOT NULL
);

CREATE TABLE "PickUpOptions" (
  "PickUpID" serial PRIMARY KEY,
  "DeliveryType" text NOT NULL
);

CREATE TABLE "OrderDetails" (
  "OrderDetailID" serial PRIMARY KEY,
  "OrderID" int NOT NULL,
  "ProductID" int NOT NULL,
  "Quantity" int NOT NULL,
  "TotalAmount" decimal NOT NULL,
  UNIQUE ("OrderID", "ProductID")
);

ALTER TABLE IF EXISTS "Clients" ADD FOREIGN KEY ("AddressID") REFERENCES "Addresses" ("AddressID");

ALTER TABLE IF EXISTS "Addresses" ADD FOREIGN KEY ("CityID") REFERENCES "Cities" ("CityID");

ALTER TABLE IF EXISTS "Products" ADD FOREIGN KEY ("CategoryID") REFERENCES "Categories" ("CategoryID");

ALTER TABLE IF EXISTS "Orders" ADD FOREIGN KEY ("ClientID") REFERENCES "Clients" ("ClientID");

ALTER TABLE IF EXISTS "OrderDetails" ADD FOREIGN KEY ("OrderID") REFERENCES "Orders" ("OrderID");

ALTER TABLE IF EXISTS "OrderDetails" ADD FOREIGN KEY ("ProductID") REFERENCES "Products" ("ProductID");

ALTER TABLE IF EXISTS "Clients" ADD FOREIGN KEY ("Preferences_Category") REFERENCES "Categories" ("CategoryID");

ALTER TABLE IF EXISTS "Orders" ADD FOREIGN KEY ("PickUpOptions") REFERENCES "PickUpOptions" ("PickUpID");

ALTER TABLE IF EXISTS "Orders" ADD FOREIGN KEY ("StatusId") REFERENCES "Status" ("StatusID");

ALTER TABLE IF EXISTS "Products" ADD FOREIGN KEY ("ConditionID") REFERENCES "Condition" ("ConditionId");