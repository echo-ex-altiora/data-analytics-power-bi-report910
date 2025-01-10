# data-analytics-power-bi-report910


## Milestone 2 : Import Data into Power BI

Document your achievements in a comprehensive manner. Update the README file on the GitHub repository of this project with detailed information about the tasks accomplished in this milestone. For example you should describe the methods used to import the data, and the transformations you performed.

### Orders Table
Method used to import was Azure SQL Database

- delete the column named [Card Number] 
    - = Table.RemoveColumns(dbo_orders_powerbi,{"Card Number"})
- changed data type of Order and Shipping data to datetime
    - = Table.TransformColumnTypes(#"Removed Columns",{{"Order Date", type datetime}, {"Shipping Date", type datetime}})
- Split Order date into date and time
    - = Table.SplitColumn(Table.TransformColumnTypes(#"Changed Type", {{"Order Date", type text}}, "en-GB"), "Order Date", Splitter.SplitTextByDelimiter(" ", QuoteStyle.Csv), {"Order Date.1", "Order Date.2"})
- Rename columns
    - = Table.RenameColumns(#"Changed Type1",{{"Order Date.1", "Order Date"}, {"Order Date.2", "Order Time"}})
- Split Shipping date into date and time
    - = Table.SplitColumn(Table.TransformColumnTypes(#"Renamed Columns", {{"Shipping Date", type text}}, "en-GB"), "Shipping Date", Splitter.SplitTextByDelimiter(" ", QuoteStyle.Csv), {"Shipping Date.1", "Shipping Date.2"})
- Rename columns
    - = Table.RenameColumns(#"Changed Type2",{{"Shipping Date.1", "Shipping Date"}, {"Shipping Date.2", "Shipping Time"}})
- Filter out and remove any rows where the [Order Date] column has missing or null values to maintain data integrity
    - = Table.SelectRows(#"Renamed Columns1", each [Order Date] <> null and [Order Date] <> "")
- Rename the columns in your dataset to align with Power BI naming conventions, ensuring consistency and clarity in your report
    - = Table.RenameColumns(#"Filtered Rows",{{"product_code", "Product Code"}})

### Products Table
Method used to import was csv file

- Remove Duplicates function on the product_code column to ensure each product code is unique
    - = Table.Distinct(#"Changed Type", {"product_code"})
- Rename the columns in your dataset to match Power BI naming conventions
    - = Table.RenameColumns(#"Removed Duplicates",{{"description", "Description"}, {"sale_price", "Sale Price"}, {"weight", "Weight"}, {"category", "Category"}, {"date_added", "Date Added"}, {"product_uuid", "Product UUID"}, {"availability", "Availability"}, {"product_code", "Product Code"}, {"cost_price", "Cost Price"}})

### Products Table
Method used to import was Azure Blob Storage
When you initially import it, it will be a single row file. In Power Query Editor view you can click on the link under content to gain access to the csv file contained in the storage.
    - = Csv.Document(#"https://powerbistorage4776 blob core windows net/data-analytics/_Stores csv",[Delimiter=",", Columns=14, Encoding=65001, QuoteStyle=QuoteStyle.Csv])


- In the Region column, replace any misspelled regions using Replace Values tool.
    - = Table.ReplaceValue(#"Changed Type","eeEurope","Europe",Replacer.ReplaceText,{"region"})
    - = Table.ReplaceValue(#"Replaced Value","eeAmerica","America",Replacer.ReplaceText,{"region"})
- Rename the columns in your dataset to match Power BI naming conventions
    - = Table.RenameColumns(#"Replaced Value1",{{"id1", "ID1"}, {"id2", "ID2"}, {"id3", "ID3"}, {"address", "Address"}, {"longitude", "Longitude"}, {"town", "Town"}, {"store code", "Store Code"}, {"staff numbers", "Staff Numbers"}, {"date_opened", "Date Opened"}, {"store_type", "Store Type"}, {"latitude", "Latitude"}, {"country_code", "Country Code"}, {"region", "Region"}, {"country_region", "Country Region"}})

### Customers Table
Method used to import was Folder.
Download the Customers.zip file and unzip it on your local machine. As each file has the same format, they can be easily combined by selecting Combine and Transform when initially importing the data.

- Create a Full Name column by combining the [First Name] and [Last Name] columns
    - = Table.AddColumn(#"Filtered Rows", "Merged", each Text.Combine({[First Name], [Last Name]}, " "), type text)
    - = Table.ReorderColumns(#"Inserted Merged Column",{"Source.Name", "Merged", "First Name", "Last Name", "Date of Birth", "Company", "email", "Address", "Country", "Country Code", "Telephone", "Join Date", "User UUID"})
- Rename the columns in your dataset to match Power BI naming conventions
    - = Table.RenameColumns(#"Reordered Columns",{{"Merged", "Full Name"}, {"email", "Email"}})
- Delete any obviously unused columns
    - = Table.RemoveColumns(#"Filtered Rows1",{"Source.Name"})

### Save 
Also save the latest version of your Power BI .pbix file and upload it to the Github repository.

## Milestone 3 :

### Task 1 : Date Table

- Make date table 
    - Date = CALENDAR(DATE(2010,1,1), DATE(2023,12,31))
    - Mark as Date table

- add columns to your date table:
    - Day of Week
        - Day of Week = FORMAT('Date'[Date],"dddd")
        - Day Of Week Number = WEEKDAY('Date'[Date], 2)
    - Month Number (i.e. Jan = 1, Dec = 12 etc.)
        - Month Number = MONTH('Date'[Date])
    - Month Name
        - Month Name = FORMAT('Date'[Date],"mmmm")
    - Quarter
        - Quarter = QUARTER('Date'[Date])
    - Year
        - Year = YEAR('Date'[Date])
    
    - Start of Year
        - Start Of Year = STARTOFYEAR('Date'[Date])
    - Start of Quarter
        - Start Of Quarter = STARTOFQUARTER('Date'[Date])
    - Start of Month
        - Start Of Month = STARTOFMONTH('Date'[Date])
    - Start of Week
        - Start Of Week = 'Date'[Date] - WEEKDAY('Date'[Date],2) + 1
    
    - Week Number
        - Week Number = WEEKNUM('Date'[Date])

### Task 2 : Star Schema

Create relationships between the tables to form a star schema

- Products[Product Code] to Orders[Product Code]
- Stores[Store code] to Orders[Store Code]
- Customers[User UUID] to Orders[User ID]
- Date[date] to Orders[Order Date]
- Date[date] to Orders[Shipping Date]

All relationships are one-to-many with a single filter direction flowing from the dimension table side to the fact table side 

There are two reltionships between Orders and Date tables but Date[date] to Orders[Order Date] is the active relationship.

### Task 3 : Measures Table

Creating a measures table keeps the data model organized and easy to navigate.
From the Model view, select Enter Data from the Home tab of the ribbon; name the new blank table Measures Table and then click Load

### Task 4 : Key Measures

1. Create a measure called Total Orders that counts the number of orders in the Orders table
    - Total Orders = COUNT(Orders[Order Date])

2. Create a measure called Total Revenue that multiplies the Orders[Product Quantity] column by the Products[Sale Price] column for each row, and then sums the result
    - Total Revenue = SUMX(Orders, Orders[Product Quantity] * RELATED(Products[Sale Price]))

3. Create a measure called Total Profit which performs the following calculation:
    - For each row, subtract the Products[Cost Price] from the Products[Sale Price], and then multiply the result by the Orders[Product Quantity]
    - Sums the result for all rows
        - Total Profit = SUMX(Orders, (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])) * Orders[Product Quantity])

4. Create a measure called Total Customers that counts the number of unique customers in the Orders table. This measure needs to change as the Orders table is filtered, so do not just count the rows of the Customers table!
    - Total Customers = DISTINCTCOUNT(Orders[User ID])

5. Create a measure called Total Quantity that counts the number of items sold in the Orders table
    - Total Quantity = SUM(Orders[Product Quantity])

6.Create a measure called Profit YTD that calculates the total profit for the current year
    - Profit YTD = TOTALYTD([Total Profit], 'Date'[Date])

7. Create a measure called Revenue YTD that calculates the total revenue for the current year
    - Revenue YTD = TOTALYTD([Total Revenue], 'Date'[Date])

### Task 5 : Date and Geography Hierarchies

#### Date Hierarchies

Date Hierarchy has the following levels
    - Start of Year
    - Start of Quarter
    - Start of Month
    - Start of Week
    - Date

#### Calculated column : Country

Create a new calculated column in the Stores table called Country that creates a full country name for each row, based on the Stores[Country Code] column.
    - Country = SWITCH([Country Code], "GB", "United Kingdom", "US", "United States", "DE", "Germany")

#### Calculated column : Geography

Create a new calculated column in the Stores table called Geography that creates a full geography name for each row, based on the Stores[Country Region], and Stores[Country] columns, separated by a comma and a space.
    - Geography = Stores[Country Region] & ", " & Stores[Country]

#### Geography : Data Types

Change Data Categories in column tools for the Stores Table as below:
    - Region : Continent
    - Country : Country
    - Country Region : State or Province

#### Geography Hierarchies

Geography hierarchy has the following levels
    - World Region
    - Country
    - Country Region

### Save

Also save the latest version of your Power BI .pbix file and upload it to the Github repository.