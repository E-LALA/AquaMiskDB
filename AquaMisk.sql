-- Database Setup and Business Queries for Maintenance and Inventory Management System (AquaMisk water filteration systems.)

-- ==========================
-- SECTION 1: Table Creation
-- ==========================

-- Drop existing tables (if any)
IF OBJECT_ID('MaintenanceParts', 'U') IS NOT NULL DROP TABLE MaintenanceParts;
IF OBJECT_ID('Maintenance', 'U') IS NOT NULL DROP TABLE Maintenance;
IF OBJECT_ID('MobileNumbers', 'U') IS NOT NULL DROP TABLE MobileNumbers;
IF OBJECT_ID('Employees', 'U') IS NOT NULL DROP TABLE Employees;
IF OBJECT_ID('Customers', 'U') IS NOT NULL DROP TABLE Customers;
IF OBJECT_ID('PartsInventory', 'U') IS NOT NULL DROP TABLE PartsInventory;

-- Create PartsInventory table
CREATE TABLE PartsInventory (
    PartID INT PRIMARY KEY,
    PartName NVARCHAR(100) NOT NULL,
    StockQuantity INT NOT NULL CHECK (StockQuantity >= 0),
    UnitPrice DECIMAL(10, 2) NOT NULL
);

-- Create Customers table
CREATE TABLE Customers (
    CustomerCode INT PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255),
    InstallDate DATE
);

-- Create MobileNumbers table
CREATE TABLE MobileNumbers (
    CustomerCode INT NOT NULL,
    MobileNumber NVARCHAR(15) NOT NULL,
    PRIMARY KEY (CustomerCode, MobileNumber),
    FOREIGN KEY (CustomerCode) REFERENCES Customers(CustomerCode)
);

-- Create Employees table
CREATE TABLE Employees (
    EmployeeMobile NVARCHAR(15) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

-- Create Maintenance table
CREATE TABLE Maintenance (
    MaintenanceID INT PRIMARY KEY,
    RecentMaintenance DATE,
    UpcomingMaintenance DATE CHECK (UpcomingMaintenance > RecentMaintenance),
    Comment NVARCHAR(MAX),
    RecentMaintenanceEmployee NVARCHAR(15),
    CustomerCode INT NOT NULL,
    FOREIGN KEY (RecentMaintenanceEmployee) REFERENCES Employees(EmployeeMobile),
    FOREIGN KEY (CustomerCode) REFERENCES Customers(CustomerCode)
);

-- Create MaintenanceParts table
CREATE TABLE MaintenanceParts (
    MaintenanceID INT PRIMARY KEY,
    PartID INT NOT NULL,
    PartName NVARCHAR(100) NOT NULL,
    Quantity INT NOT NULL,
    PartCost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (PartID) REFERENCES PartsInventory(PartID)
);

-- ==========================
-- SECTION 2: Stored Procedures and Functions
-- ==========================

-- Stored procedure to add a new maintenance record
CREATE PROCEDURE AddMaintenance 
    @CustomerCode INT,
    @RecentDate DATE,
    @UpcomingDate DATE,
    @Comment NVARCHAR(MAX),
    @EmployeeMobile NVARCHAR(15)
AS
BEGIN
    INSERT INTO Maintenance (CustomerCode, RecentMaintenance, UpcomingMaintenance, Comment, RecentMaintenanceEmployee)
    VALUES (@CustomerCode, @RecentDate, @UpcomingDate, @Comment, @EmployeeMobile);
END;
GO

-- Function to calculate average maintenance cost per customer
CREATE FUNCTION AverageMaintenanceCost (@CustomerCode INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @AvgCost DECIMAL(10,2);
    SELECT @AvgCost = AVG(mp.Quantity * mp.PartCost)
    FROM MaintenanceParts mp
    JOIN Maintenance m ON mp.MaintenanceID = m.MaintenanceID
    WHERE m.CustomerCode = @CustomerCode;
    RETURN @AvgCost;
END;
GO
-- Function to return Customers with Maintenance This Month
CREATE FUNCTION GetCustomersWithMaintenanceThisMonth()
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT c.CustomerID, c.CustomerName, c.Address
    FROM Customers c
    JOIN Maintenance m ON c.CustomerID = m.CustomerCode
    WHERE MONTH(m.UpcomingDate) = MONTH(GETDATE()) AND YEAR(m.UpcomingDate) = YEAR(GETDATE())
);

-- ==========================
-- SECTION 3: Triggers
-- ==========================

-- Trigger to update stock when parts are used
CREATE TRIGGER UpdateStockAfterUsage
ON MaintenanceParts
AFTER INSERT
AS
BEGIN
    UPDATE PartsInventory
    SET StockQuantity = StockQuantity - i.Quantity
    FROM inserted i
    WHERE PartsInventory.PartID = i.PartID;
END;
GO

-- Trigger to alert when stock is below critical level
CREATE TRIGGER StockAlert
ON PartsInventory
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE StockQuantity < 5
    )
    BEGIN
        RAISERROR ('Stock level critically low!', 16, 1);
    END;
END;
GO

-- ==========================
-- SECTION 4: Indexes
-- ==========================

-- Add indexes for faster queries
CREATE INDEX idx_customer_code ON Customers (CustomerCode);
CREATE INDEX idx_part_id ON PartsInventory (PartID);
CREATE INDEX idx_employee_mobile ON Employees (EmployeeMobile);

-- ==========================
-- SECTION 5: Sample Data hidden for views.
-- ==========================

-- Insert sample data into PartsInventory
INSERT INTO PartsInventory (PartID, PartName, StockQuantity, UnitPrice)
VALUES
(1, 'Membrane', 50, 300.00),
(2, '1st stage', 200, 50.00),
(3, '2nd stage', 100, 75.00);

-- Insert sample data into Customers
INSERT INTO Customers (CustomerCode, CustomerName, Address, InstallDate)
VALUES
(1, '****** *******', 'TANTA ************', '2023-01-15'),
(2, '***** *******', 'CAIRO **************', '2023-05-20');

-- Insert sample data into Employees
INSERT INTO Employees (EmployeeMobile, Name)
VALUES
('***********', '***********'),
('***********', '*******');

-- Insert sample data into Maintenance
INSERT INTO Maintenance (MaintenanceID, RecentMaintenance, UpcomingMaintenance, Comment, RecentMaintenanceEmployee, CustomerCode)
VALUES
(1, '2025-01-01', '2025-06-01', 'Regular service', '**********', 1),
(2, '2025-03-15', '2025-09-15', 'Reguler service', '**********', 2);

-- Insert sample data into MaintenanceParts
INSERT INTO MaintenanceParts (MaintenanceID, PartID, PartName, Quantity, PartCost)
VALUES
(1, 1, '1st stage', 2, 50.00),
(2, 2, 'Membrane', 1, 3000.00);

-- ==========================
-- SECTION 6: Business Queries
-- ==========================

-- Query to check low stock parts
SELECT PartID, PartName, StockQuantity
FROM PartsInventory
WHERE StockQuantity < 10;

-- Query to calculate total inventory value
SELECT SUM(StockQuantity * UnitPrice) AS TotalInventoryValue
FROM PartsInventory;

-- Query to track part usage in maintenance
SELECT p.PartName, SUM(mp.Quantity) AS TotalUsed
FROM MaintenanceParts mp
JOIN PartsInventory p ON mp.PartID = p.PartID
GROUP BY p.PartName
ORDER BY TotalUsed DESC;

-- Query to find the most frequently used parts
SELECT p.PartName, COUNT(mp.PartID) AS UsageCount
FROM MaintenanceParts mp
JOIN PartsInventory p ON mp.PartID = p.PartID
GROUP BY p.PartName
ORDER BY UsageCount DESC;

-- Query to get upcoming maintenance for a specific customer
SELECT m.MaintenanceID, c.CustomerName, m.UpcomingMaintenance, m.Comment
FROM Maintenance m
JOIN Customers c ON m.CustomerCode = c.CustomerCode
WHERE c.CustomerName = 'John Doe'
  AND m.UpcomingMaintenance > GETDATE();

