--*************************************************************************--
-- Title: Assignment06
-- Author: VladimirSemenovich
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2025-05-27,VladimirSemenovich,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_VladimirSemenovich')
	 Begin 
	  Alter Database [Assignment06DB_VladimirSemenovich] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_VladimirSemenovich;
	 End
	Create Database Assignment06DB_VladimirSemenovich;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_VladimirSemenovich;

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

-- View for Categories Table
If Object_Id('dbo.vCategories') Is Not Null
  Drop View dbo.vCategories;
go
Create View dbo.vCategories
With Schemabinding
As
  Select
    CategoryID,
    CategoryName
  From dbo.Categories;
go

-- View for Products Table
If Object_Id('dbo.vProducts') Is Not Null
  Drop View dbo.vProducts;
go
Create View dbo.vProducts
With Schemabinding
As
  Select
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice
  From dbo.Products;
go

-- View for Employees Table
If Object_Id('dbo.vEmployees') Is Not Null
  Drop View dbo.vEmployees;
go
Create View dbo.vEmployees
With Schemabinding
As
  Select
    EmployeeID,
    EmployeeFirstName,
    EmployeeLastName,
    ManagerID
  From dbo.Employees;
go

-- View for Inventories Table
If Object_Id('dbo.vInventories') Is Not Null
  Drop View dbo.vInventories;
go
Create View dbo.vInventories
With Schemabinding
As
  Select
    InventoryID,
    InventoryDate,
    EmployeeID,
    ProductID,
    [Count]
  From dbo.Inventories;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Deny SELECT on base tables to Public
Print 'Denying SELECT on base tables to Public role...';
Deny Select On dbo.Categories To Public;
go
Deny Select On dbo.Products To Public;
go
Deny Select On dbo.Employees To Public;
go
Deny Select On dbo.Inventories To Public;
go
Print 'SELECT on base tables to Public role DENIED.';
go

-- Grant SELECT on views to Public
Print 'Granting SELECT on views to Public role...';
Grant Select On dbo.vCategories To Public;
go
Grant Select On dbo.vProducts To Public;
go
Grant Select On dbo.vEmployees To Public;
go
Grant Select On dbo.vInventories To Public;
go
Print 'SELECT on basic views to Public role GRANTED for Question 2.';
go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

If Object_Id('dbo.vProductsByCategories') Is Not Null
  Drop View dbo.vProductsByCategories;
go
Create View dbo.vProductsByCategories
With Schemabinding
As
  Select Top 100 Percent
    vc.CategoryName,
    vp.ProductName,
    vp.UnitPrice
  From dbo.vCategories As vc
  Inner Join dbo.vProducts As vp On vc.CategoryID = vp.CategoryID
  Order By
    vc.CategoryName,
    vp.ProductName;
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

If Object_Id('dbo.vInventoriesByProductsByDates') Is Not Null
  Drop View dbo.vInventoriesByProductsByDates;
go
Create View dbo.vInventoriesByProductsByDates
With Schemabinding
As
  Select Top 100 Percent
    vp.ProductName,
    vi.InventoryDate,
    vi.[Count]
  From dbo.vInventories As vi
  Inner Join dbo.vProducts As vp On vi.ProductID = vp.ProductID
  Order By
    vp.ProductName,
    vi.InventoryDate,
    vi.[Count];
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

If Object_Id('dbo.vInventoriesByEmployeesByDates') Is Not Null
  Drop View dbo.vInventoriesByEmployeesByDates;
go
Create View dbo.vInventoriesByEmployeesByDates
With Schemabinding
As
  Select Top 100 Percent
    vi.InventoryDate,
    ve.EmployeeFirstName + ' ' + ve.EmployeeLastName As EmployeeName
  From dbo.vInventories As vi
  Inner Join dbo.vEmployees As ve On vi.EmployeeID = ve.EmployeeID
  Inner Join (
    Select
      InventoryDate,
      Min(EmployeeID) As MinEmployeeID
    From dbo.vInventories
    Group By InventoryDate
  ) As UniqueEmployeePerDate On vi.InventoryDate = UniqueEmployeePerDate.InventoryDate
                               And vi.EmployeeID = UniqueEmployeePerDate.MinEmployeeID
  Order By
    vi.InventoryDate;
go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

If Object_Id('dbo.vInventoriesByProductsByCategories') Is Not Null
  Drop View dbo.vInventoriesByProductsByCategories;
go
Create View dbo.vInventoriesByProductsByCategories
With Schemabinding
As
  Select Top 100 Percent
    vc.CategoryName,
    vp.ProductName,
    vi.InventoryDate,
    vi.[Count]
  From dbo.vCategories As vc
  Inner Join dbo.vProducts As vp On vc.CategoryID = vp.CategoryID
  Inner Join dbo.vInventories As vi On vp.ProductID = vi.ProductID
  Order By
    vc.CategoryName,
    vp.ProductName,
    vi.InventoryDate,
    vi.[Count];
go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

If Object_Id('dbo.vInventoriesByProductsByEmployees') Is Not Null
  Drop View dbo.vInventoriesByProductsByEmployees;
go
Create View dbo.vInventoriesByProductsByEmployees
With Schemabinding
As
  Select Top 100 Percent
    vc.CategoryName,
    vp.ProductName,
    vi.InventoryDate,
    vi.[Count],
    ve.EmployeeFirstName + ' ' + ve.EmployeeLastName As EmployeeName
  From dbo.vCategories As vc
  Inner Join dbo.vProducts As vp On vc.CategoryID = vp.CategoryID
  Inner Join dbo.vInventories As vi On vp.ProductID = vi.ProductID
  Inner Join dbo.vEmployees As ve On vi.EmployeeID = ve.EmployeeID
  Order By
    vi.InventoryDate,
    vc.CategoryName,
    vp.ProductName,
    EmployeeName;
go


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

If Object_Id('dbo.vInventoriesForChaiAndChangByEmployees') Is Not Null
  Drop View dbo.vInventoriesForChaiAndChangByEmployees;
go
Create View dbo.vInventoriesForChaiAndChangByEmployees
With Schemabinding
As
  Select Top 100 Percent
    vc.CategoryName,
    vp.ProductName,
    vi.InventoryDate,
    vi.[Count],
    ve.EmployeeFirstName + ' ' + ve.EmployeeLastName As EmployeeName
  From dbo.vCategories As vc
  Inner Join dbo.vProducts As vp On vc.CategoryID = vp.CategoryID
  Inner Join dbo.vInventories As vi On vp.ProductID = vi.ProductID
  Inner Join dbo.vEmployees As ve On vi.EmployeeID = ve.EmployeeID
  Where vp.ProductName In ('Chai', 'Chang')
  Order By
    vc.CategoryName,
    vp.ProductName,
    vi.InventoryDate,
    EmployeeName;
go



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

If Object_Id('dbo.vEmployeesByManager') Is Not Null
  Drop View dbo.vEmployeesByManager;
go
Create View dbo.vEmployeesByManager
With Schemabinding
As
  Select Top 100 Percent
    Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName As ManagerName,
    Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName As EmployeeName
  From dbo.vEmployees As Emp
  Inner Join dbo.vEmployees As Mgr On Emp.ManagerID = Mgr.EmployeeID
  Order By
    ManagerName,
    EmployeeName;
go


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

If Object_Id('dbo.vInventoriesByProductsByCategoriesByEmployees') Is Not Null
  Drop View dbo.vInventoriesByProductsByCategoriesByEmployees;
go
Create View dbo.vInventoriesByProductsByCategoriesByEmployees
With Schemabinding
As
  Select Top 100 Percent
    vCat.CategoryID,
    vCat.CategoryName,
    vProd.ProductID,
    vProd.ProductName,
    vProd.UnitPrice,
    vInv.InventoryID,
    vInv.InventoryDate,
    vInv.[Count],
    InvEmp.EmployeeID As InventoryTakerEmployeeID,
    InvEmp.EmployeeFirstName + ' ' + InvEmp.EmployeeLastName As InventoryTakerFullName,
    Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName As ManagerName
  From
    dbo.vCategories As vCat
    Inner Join dbo.vProducts As vProd On vCat.CategoryID = vProd.CategoryID
    Inner Join dbo.vInventories As vInv On vProd.ProductID = vInv.ProductID
    Inner Join dbo.vEmployees As InvEmp On vInv.EmployeeID = InvEmp.EmployeeID
    Inner Join dbo.vEmployees As Mgr On InvEmp.ManagerID = Mgr.EmployeeID
  Order By
    vCat.CategoryName,
    vProd.ProductName,
    vInv.InventoryID,
    InventoryTakerFullName;
go


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