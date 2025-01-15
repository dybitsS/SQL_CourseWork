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
    CitiesKey SERIAL PRIMARY KEY,
    CitySK INT NOT NULL,
    CityName VARCHAR(255) NOT NULL
);

CREATE TABLE DimAddresses (
    AddressesKey SERIAL PRIMARY KEY,
    AddressSK INT NOT NULL,
    Street VARCHAR(255),
    CitySK INT NOT NULL,
    PostalCode VARCHAR(20),
    Country VARCHAR(100),
    FOREIGN KEY (CitySK) REFERENCES DimCities(CitiesKey)
);

CREATE TABLE DimConditions (
    ConditionsKey SERIAL PRIMARY KEY,
    ConditionSK INT NOT NULL,
    Name VARCHAR(255) NOT NULL
);

CREATE TABLE DimCategories (
    CategoriesKey SERIAL PRIMARY KEY,
    CategorySK INT NOT NULL,
    Name VARCHAR(255) NOT NULL
);

CREATE TABLE DimStatus (
    StatusKey SERIAL PRIMARY KEY,
    StatusSK INT NOT NULL,
    Name VARCHAR(255) NOT NULL
);

CREATE TABLE DimPickUp (
    PickUpKey SERIAL PRIMARY KEY,
    PickUpSK INT NOT NULL,
    Name VARCHAR(255) NOT NULL
);

CREATE TABLE DimDates (
    DatesKey SERIAL PRIMARY KEY,
    Date DATE NOT NULL,
    Year INT,
    Month INT,
    Day INT,
    Week INT,
    Quarter INT
);

CREATE TABLE DimProducts (
    ProductsKey SERIAL PRIMARY KEY,
    ProductSK INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    CategorySK INT NOT NULL,
    ConditionSK INT NOT NULL,
    Era VARCHAR(100) NOT NULL,
    Price DECIMAL(12, 2) NOT NULL,
    IsCurrent BOOLEAN NOT NULL DEFAULT TRUE,
    StartDateID INT NOT NULL,
    EndDateID INT,
    FOREIGN KEY (CategorySK) REFERENCES DimCategories(CategoriesKey),
    FOREIGN KEY (ConditionSK) REFERENCES DimConditions(ConditionsKey),
    FOREIGN KEY (StartDateID) REFERENCES DimDates(DatesKey),
    FOREIGN KEY (EndDateID) REFERENCES DimDates(DatesKey)
);

CREATE TABLE DimClients (
    ClientsKey SERIAL PRIMARY KEY,
    ClientSK INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    PhoneNumber VARCHAR(20),
    AddressSK INT NOT NULL,
    PreferencesCategorySK INT NOT NULL,
    IsCurrent BOOLEAN NOT NULL DEFAULT TRUE,
    StartDateID INT NOT NULL,
    EndDateID INT,
    FOREIGN KEY (AddressSK) REFERENCES DimAddresses(AddressesKey),
    FOREIGN KEY (PreferencesCategorySK) REFERENCES DimCategories(CategoriesKey),
    FOREIGN KEY (StartDateID) REFERENCES DimDates(DatesKey),
    FOREIGN KEY (EndDateID) REFERENCES DimDates(DatesKey)
);

CREATE TABLE FactSales (
    SalesID SERIAL PRIMARY KEY,
    DatesKey INT NOT NULL,
    ProductSK INT NOT NULL,
    ClientSK INT NOT NULL,
    StatusSK INT NOT NULL,
    PickUpSK INT NOT NULL,
    Quantity INT NOT NULL,
    TotalSalesAmount DECIMAL(12, 2),
    FOREIGN KEY (DatesKey) REFERENCES DimDates(DatesKey),
    FOREIGN KEY (ProductSK) REFERENCES DimProducts(ProductsKey),
    FOREIGN KEY (ClientSK) REFERENCES DimClients(ClientsKey),
    FOREIGN KEY (StatusSK) REFERENCES DimStatus(StatusKey),
    FOREIGN KEY (PickUpSK) REFERENCES DimPickUp(PickUpKey),
    UNIQUE (ClientSK, ProductSK, DatesKey)
);

CREATE TABLE FactInventory (
    InventoryID SERIAL PRIMARY KEY,
    ProductSK INT NOT NULL,
    DatesKey INT NOT NULL,
    StockQuantity INT NOT NULL,
    FOREIGN KEY (ProductSK) REFERENCES DimProducts(ProductsKey),
    FOREIGN KEY (DatesKey) REFERENCES DimDates(DatesKey),
    UNIQUE (DatesKey, ProductSK)
);
