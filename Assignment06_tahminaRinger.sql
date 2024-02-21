--*************************************************************************--
-- Title: Assignment06
-- Author: TahminaRinger
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-02-18,TahminaRinger,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TahminaRinger')
	 Begin 
	  Alter Database [Assignment06DB_TahminaRinger] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TahminaRinger;
	 End
	Create Database Assignment06DB_TahminaRinger;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TahminaRinger;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--Get all columns from Categories
SELECT * FROM Categories;
GO
-- Get specific columns from categories table
SELECT CategoryID, CategoryName FROM Categories;
GO
--Creat a view of all columns from Categories
CREATE VIEW vCategories AS
SELECT C.CategoryID, C.CategoryName
FROM Categories AS C;
GO
--Select all from view to confirm is as expected
SELECT * FROM vCategories;
GO

--Select all products
SELECT * FROM Products;
GO
-- Select all columns needed from products table
SELECT ProductID, ProductName, CategoryID, UnitPrice FROM Products;
GO
--Create view of all columns from the products table 
CREATE VIEW vProducts AS
SELECT P.ProductID, P.ProductName, P.CategoryID, P.UnitPrice
FROM Products AS P;
GO
--Select all from vProducts view to confirm it was created as expected
SELECT * FROM vProducts;
GO

--Select all from the Employees table
SELECT * FROM Employees;
GO
-- Select all needed columns from Employees table
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID FROM Employees;
GO
--Create an employees view will all columns from the table
CREATE VIEW vEmployees AS
SELECT E.EmployeeID, EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName, E.ManagerID
FROM Employees AS E;
GO
--Select all columns from view to confirm match the requests
SELECT * FROM vEmployees;
GO

--Get all columns from Inventories table
SELECT * FROM Inventories;
GO
--get all column needed from inventories table
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count] FROM Inventories;
GO
--Create a view for inventories
CREATE VIEW vInventories AS
SELECT I.InventoryID, I.InventoryDate, I.EmployeeID, I.ProductID, I.[Count]
FROM Inventories AS I;
GO
--select all from view to see if it created as designed
SELECT * FROM vInventories;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--CANNOT select data from Categories table
DENY SELECT ON Categories TO PUBLIC;
GO
-- but CAN select data from the view
GRANT SELECT ON vCategories TO PUBLIC;
GO

--CANNOT select data from Products table
DENY SELECT ON Products TO PUBLIC;
GO
-- but CAN select data from the view
GRANT SELECT ON vProducts TO PUBLIC;
GO

--CANNOT select data from Employees table
DENY SELECT ON Employees TO PUBLIC;
GO
-- but CAN select data from the view
GRANT SELECT ON vEmployees TO PUBLIC;
GO

--CANNOT select data from Inventories table
DENY SELECT ON Inventories TO PUBLIC;
GO
-- but CAN select data from the view
GRANT SELECT ON vInventories TO PUBLIC;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--Get all columns from categories and products
SELECT * FROM vCategories;
GO
SELECT * FROM vProducts;
GO

-- Select specific columns from tables to view
SELECT CategoryName FROM vCategories;
GO
SELECT ProductName, UnitPrice FROM vProducts;
GO
-- Create a view that selects specified columns and joins categories and products
CREATE VIEW vProductsByCategories AS
SELECT C.CategoryName, P.ProductName, P.UnitPrice
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
GO

--Check view 
SELECT * FROM vProductsByCategories;
GO

--Alter the view to order by categoryName and then productName
ALTER VIEW vProductsByCategories AS
SELECT TOP 10000 C.CategoryName, P.ProductName, P.UnitPrice
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
ORDER BY CategoryName, ProductName;
GO

--Check view sort order
SELECT * FROM vProductsByCategories;
GO


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--select all columns in products
SELECT * FROM vProducts;
GO
--select all columns in inventories
SELECT * FROM vInventories;
GO

-- Create a view that selects specified columns and joins inventories and products
-- DROP VIEW vInventoryInformationPerDate;
-- GO
CREATE VIEW vInventoriesByProductsByDates AS
SELECT P.ProductName, I.InventoryDate, I.[Count]
FROM vProducts AS P
JOIN vInventories AS I
ON P.ProductID = I.ProductID
GO
--Check content of view
SELECT * FROM vInventoriesByProductsByDates;
GO

--Order view to Product, Date, and Count
ALTER VIEW vInventoriesByProductsByDates AS
SELECT TOP 10000 P.ProductName, I.InventoryDate, I.[Count]
FROM vProducts AS P
JOIN vInventories AS I
ON P.ProductID = I.ProductID
ORDER BY P.ProductName, I.InventoryDate, I.[Count];
GO
--Check content of view matcheds Order By
SELECT * FROM vInventoriesByProductsByDates;


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Select all columns form inventories and employees tables
SELECT * FROM vInventories;
GO
SELECT * FROM vEmployees;
GO

-- Select the IventoryDate and EmployeeID column from inventories table
SELECT InventoryDate, EmployeeID FROM vInventories;
GO
-- Select EmployeeID and name from Employees table
SELECT EmployeeID, EmployeeName FROM vEmployees;
GO

-- Create a view with selected columns
-- DROP VIEW vInventoryDateByEmployee;
CREATE VIEW vInventoriesByEmployeesByDates AS
SELECT DISTINCT I.InventoryDate, EmployeeName
FROM vInventories AS I
JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID;
GO
--Check to see if view created properly
SELECT * FROM vInventoriesByEmployeesByDates;
GO


-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Get all categories
SELECT * FROM vCategories;
GO
--Get all Products
SELECT * FROM vProducts
GO
--Get all Inventories
SELECT * FROM vInventories;
GO

-- Get specified columns 
SELECT CategoryName FROM vCategories;
GO
SELECT ProductName FROM vProducts;
GO
SELECT InventoryDate, [Count] FROM vInventories;
GO

--Create the view with the specified columns
CREATE VIEW vInventoriesByProductsByCategories AS
SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count] 
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON I.ProductID = P.ProductID;
GO

--Check what was added to the view
SELECT * FROM vInventoriesByProductsByCategories;
GO

--Alter the view to be ordered by Category, Product, Date, and Count
ALTER VIEW vInventoriesByProductsByCategories AS
SELECT TOP 10000 C.CategoryName, P.ProductName, I.InventoryDate, I.[Count] 
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON I.ProductID = P.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, [Count];
GO
SELECT * FROM vInventoriesByProductsByCategories;
GO
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
--Get all categories
SELECT * FROM vCategories;
GO
--Get all Products
SELECT * FROM vProducts;
GO
--Get all Inventories
SELECT * FROM vInventories;
GO
-- Get all Employees
SELECT * FROM vEmployees;
GO

-- Get specified columns 
SELECT CategoryName, CategoryID FROM vCategories;
GO
SELECT ProductName, ProductID, CategoryID FROM vProducts;
GO
SELECT InventoryDate, [Count], EmployeeID, ProductID FROM vInventories;
GO
SELECT EmployeeName, EmployeeID FROM vEmployees;
GO

-- DROP VIEW vInventoriesByProductsByEmployees;
-- GO
--Create view with selected table columns from Categories, Products, Inventories and the Employees tables
CREATE VIEW vInventoriesByProductsByEmployees AS
SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], EmployeeName
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON P.ProductID = I.ProductID
JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID;
GO

SELECT * FROM vInventoriesByProductsByEmployees;
GO

--Order view by Inventory Date, Category, Product and Employee
ALTER VIEW vInventoriesByProductsByEmployees AS
SELECT TOP 10000 C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], EmployeeName
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON P.ProductID = I.ProductID
JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID
ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO

SELECT * FROM vInventoriesByProductsByEmployees;
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
--Get all categories
SELECT * FROM vCategories;
GO
--Get all Products
SELECT * FROM vProducts;
GO
--Get all Inventories
SELECT * FROM vInventories;
GO
-- Get all Employees
SELECT * FROM vEmployees;
GO

-- Get specified columns 
SELECT CategoryName, CategoryID FROM vCategories;
GO
SELECT ProductName, ProductID, CategoryID FROM vProducts;
GO
SELECT InventoryDate, [Count], EmployeeID, ProductID FROM vInventories;
GO
SELECT EmployeeName, EmployeeID FROM vEmployees;
GO

CREATE VIEW vInventoriesForChaiAndChangByEmployees AS
SELECT CategoryName, ProductName, InventoryDate, [Count], EmployeeName
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON P.ProductID = I.ProductID
JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID;
GO

SELECT * FROM vInventoriesForChaiAndChangByEmployees;
GO

--add subquery to filter to Chai and Chang
ALTER VIEW vInventoriesForChaiAndChangByEmployees AS
SELECT CategoryName, ProductName, InventoryDate, [Count], EmployeeName
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON P.ProductID = I.ProductID
JOIN vEmployees AS E
ON I.EmployeeID = E.EmployeeID
WHERE I.ProductID in (SELECT ProductID From vProducts WHERE ProductName In ('Chai', 'Chang'));
GO

SELECT * FROM vInventoriesForChaiAndChangByEmployees;
GO



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--get all from employees table
SELECT * FROM vEmployees;
GO

SELECT EmployeeID, EmployeeName, ManagerID FROM vEmployees;
GO

--Create the view with selected columns
CREATE VIEW vEmployeesByManager AS
SELECT 
	Manager = IIF(ISNULL(M.EmployeeID, 0) = 0, 'General Manger', M.EmployeeName), 
	E.EmployeeName
FROM vEmployees AS E
INNER JOIN vEmployees AS M
ON E.ManagerID = M.EmployeeID;
GO

--Check view has requested data
SELECT * FROM vEmployeesByManager;
GO

--Order view by managers name

ALTER VIEW vEmployeesByManager AS
SELECT TOP 100000
	Manager = IIF(ISNULL(M.EmployeeID, 0) = 0, 'General Manger', M.EmployeeName), 
	E.EmployeeName 
FROM vEmployees AS E
INNER JOIN vEmployees AS M
ON E.ManagerID = M.EmployeeID
ORDER BY Manager, EmployeeName;
GO

--Check view is ordered correctly
SELECT * FROM vEmployeesByManager;
GO
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
-- Get all data from views
SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vInventories;
SELECT * FROM vEmployees;

-- get all data from all columns
SELECT CategoryID, CategoryName FROM vCategories;
SELECT ProductID, ProductName, CategoryID, UnitPrice FROM vProducts;
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count] FROM vInventories;
SELECT EmployeeID, EmployeeName, ManagerID FROM vEmployees;
GO

--Create a view of all column data from all four views
--DROP VIEW vInventoriesByProductsByCategoriesByEmployees
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
SELECT 
	C.CategoryID, C.CategoryName, 
	P.ProductID, P.ProductName, P.UnitPrice,
	I.InventoryID, I.InventoryDate, I.[Count],
	E.EmployeeID, E.EmployeeName, E.ManagerID,
	Manager = IIF(ISNULL(M.EmployeeID, 0) = 0, 'General Manger', M.EmployeeName)
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON I.ProductID = P.ProductID
JOIN vEmployees AS E
ON E.EmployeeID = I.EmployeeID
INNER JOIN vEmployees AS M
ON E.ManagerID = M.EmployeeID;
GO

--Check view has requested data
SELECT * FROM vInventoriesByProductsByCategoriesByEmployees;
GO

--Order view to Category, Product, InventoryID, and Employee
ALTER VIEW vInventoriesByProductsByCategoriesByEmployees AS
SELECT TOP 100000
	C.CategoryID, C.CategoryName, 
	P.ProductID, P.ProductName, P.UnitPrice,
	I.InventoryID, I.InventoryDate, I.[Count],
	E.EmployeeID, E.EmployeeName, E.ManagerID,
	Manager = IIF(ISNULL(M.EmployeeID, 0) = 0, 'General Manger', M.EmployeeName)
FROM vCategories AS C
JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories AS I
ON I.ProductID = P.ProductID
JOIN vEmployees AS E
ON E.EmployeeID = I.EmployeeID
INNER JOIN vEmployees AS M
ON E.ManagerID = M.EmployeeID
ORDER BY CategoryID, ProductID, InventoryID, EmployeeName;
GO

--Check order by is correct
SELECT * FROM vInventoriesByProductsByCategoriesByEmployees;
GO


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/