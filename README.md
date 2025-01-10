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

Also save the latest version of your Power BI .pbix file and upload it to the Github repository.