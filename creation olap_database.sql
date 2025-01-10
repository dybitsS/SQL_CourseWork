DROP TABLE IF EXISTS 
  DimCities, 
  DimAddresses, 
  DimConditions, 
  DimCategories, 
  DimStatus,
  DimPickUp,
  DimDates, 
  DimProducts, 
  DimClients, 
  FactSales, 
  FactInventory CASCADE;

CREATE EXTENSION IF NOT EXISTS dblink;

CREATE TABLE DimCities (
    CitySK SERIAL PRIMARY KEY,
    CityName VARCHAR(255) NOT NULL);

CREATE TABLE DimAddresses (
    AddressSK SERIAL PRIMARY KEY,
    Street VARCHAR(255),
    CitySK INT NOT NULL,
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    FOREIGN KEY (CitySK) REFERENCES DimCities(CitySK));

CREATE TABLE DimConditions (
    ConditionSK SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL);

CREATE TABLE DimCategories (
    CategorySK SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL);

CREATE TABLE DimStatus (
    StatusSK SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL);

CREATE TABLE DimPickUp (
    PickUpSK SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL);

CREATE TABLE DimDates (
    DateSK SERIAL PRIMARY KEY,
    Date DATE NOT NULL,
    Year INT,
    Month INT,
    Day INT,
    Week INT,
    Quarter INT);

CREATE TABLE DimProducts (
    ProductSK SERIAL PRIMARY KEY,
    Name VARCHAR(255) unique NOT NULL,
    CategorySK INT NOT NULL,
    ConditionSK INT NOT NULL,
    Era VARCHAR(100) NOT NULL,
    Price DECIMAL(12, 2) NOT NULL,
    IsCurrent BOOLEAN NOT NULL DEFAULT TRUE,
    StartDateID INT NOT NULL,
    EndDateID INT,
    FOREIGN KEY (CategorySK) REFERENCES DimCategories(CategorySK),
    FOREIGN KEY (ConditionSK) REFERENCES DimConditions(ConditionSK),
	FOREIGN KEY (StartDateID ) REFERENCES DimDates(DateSK),
	FOREIGN KEY (EndDateID ) REFERENCES DimDates(DateSK));

CREATE TABLE DimClients (
    ClientSK SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) unique,
    PhoneNumber VARCHAR(20),
    AddressSK INT NOT NULL,
    PreferencesCategorySK INT NOT NULL,
    IsCurrent BOOLEAN NOT NULL DEFAULT TRUE,
    StartDateID INT NOT NULL,
    EndDateID INT,
    FOREIGN KEY (AddressSK) REFERENCES DimAddresses(AddressSK),
    FOREIGN KEY (PreferencesCategorySK) REFERENCES DimCategories(CategorySK),
	FOREIGN KEY (StartDateID ) REFERENCES DimDates(DateSK),
	FOREIGN KEY (EndDateID ) REFERENCES DimDates(DateSK));

CREATE TABLE FactSales (
    SalesID SERIAL PRIMARY KEY,
    DateSK INT NOT NULL,
    ProductSK INT NOT NULL,
    ClientSK INT NOT NULL,
    StatusSK INT NOT NULL,
	PickUpSK INT NOT NULL,
    Quantity INT NOT NULL,
    TotalSalesAmount DECIMAL(12, 2),
    FOREIGN KEY (DateSK) REFERENCES DimDates(DateSK),
    FOREIGN KEY (ProductSK) REFERENCES DimProducts(ProductSK),
    FOREIGN KEY (ClientSK) REFERENCES DimClients(ClientSK),
    FOREIGN KEY (StatusSK) REFERENCES DimStatus(StatusSK),
	FOREIGN KEY (PickUpSK) REFERENCES DimPickUp(PickUpSK),
    UNIQUE (ClientSK, ProductSK, DateSK));

CREATE TABLE FactInventory (
    InventoryID SERIAL PRIMARY KEY,
    ProductSK INT NOT NULL,
    DateSK INT NOT NULL,
    StockQuantity INT NOT NULL,
    FOREIGN KEY (ProductSK) REFERENCES DimProducts(ProductSK),
    FOREIGN KEY (DateSK) REFERENCES DimDates(DateSK),
    UNIQUE (DateSK, ProductSK));