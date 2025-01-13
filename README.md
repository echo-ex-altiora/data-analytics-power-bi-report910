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

### Stores Table
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

## Milestone 4 : Report 

### Create report Pages

Create four report pages and name them as follows:

    - Executive Summary
    - Customer Detail
    - Product Detail
    - Stores Map

Also choose colour scheme : Solar

### Add navigation sidebar

On the Executive Summary page, add a rectangle shape covering a narrow strip on the left side of the page. Set the fill colour to a contrasting colour of your choice. This will be the sidebar that we will use to navigate between pages later in our report build.

Duplicate the rectangle shape on each of the other pages in your report

## Milestone 5 : Customer detail

Create a report page based on customer-level analysis.
This will contain :
    - Card Visuals for total distinct customers and revenue per customer
    - A donut chart showing number of customers by country, and another showing number of customers by product category
    - A line chart of weekly distinct customers
    - A table showing the top 20 customers by total revenue, showing the revenue per customer and the total orders for each customer
    - A set of three card visuals showing the name, number of orders, and revenue for the top customer by revenue
    - a date slicer

### Task 1 : Headline Card Visuals

- Create two rectangles and arrange them in the top left corner of the page. These will serve as the backgrounds for the card visuals.
- Add a card visual for the [Total Customers] measure we created earlier. Rename the field Unique Customers. 

- Create a new measure in your Measures Table called [Revenue per Customer]. This should be the [Total Revenue] divided by the [Total Customers].
    - Revenue per Customer = [Total Revenue] / [Total Customers]
- Add a card visual for the [Revenue per Customer] measure 
    - Go to Format > Properties > Format options > Format > Currency

### Task 2 : Donut Charts

- Add a Donut Chart visual showing the total customers for each country, using the Customers[Country] column to filter the [Total Customers] measure
- Add a Donut Chart visual showing the number of customers who purchased each product category, using the Products[Category] column to filter the [Total Customers] measure

Visual
- Set background for both to transparent, legend set to off and details label set to Category

### Task 3 : Line Chart

- Add a Line Chart visual to the top of the page. It should show [Total Customers] on the Y axis, and use the Date Hierarchy we created previously for the X axis. Allow users to drill down to the month level, but not to weeks or individual dates.
    - unclick week and date
- Add a trend line, and a forecast for the next 10 periods with a 95% confidence interval
- Also add a zoom slider for the x-axis

I'm having problems with this task with making it drill down how I want
Ill move forward with the next task and then come back...

### Task 4 : Top 20 Customers Table

- Create a new table, which displays the top 20 customers, filtered by revenue. The table should show each customer's full name, revenue, and number of orders.
    - select the column customer[Full Name], measure [Total revenue] and measure [Total Orders]
    - filter Full Name by Top 20 by [Total Revenue]
    - Give table the title 'Top 20 customers'
    - sort by total revenue descending
- Add conditional formatting to the revenue column, to display data bars for the revenue values and background colour for total orders
    - go to Format > Cell Element > Total revenue and set data bars to on.
    - go to Format > Cell Element > Total orders and set background colour to on.

There is a blank name row which I will take a look at later to see if its worth deleting

### Task 5 : Top Customer Card

- Create a set of three card visuals that provide insights into the top customer by revenue. They should display the top customer's name, the number of orders made by the customer, and the total revenue generated by the customer.

For Name Card
- Field is Full Name
- Add Top N filter on full name Top 1 by value Total revenue
Set background to transparent, add a shape behind, delete category label, add title 'Top customer by revenue'

For Orders Card
- Field is Total Orders
- Add Top N filter on full name Top 1 by value Total revenue
Set background to transparent, add a shape behind, delete category label, add title 'Orders'

For Revenue Card
- Field is Total Revenue
- Add Top N filter on full name Top 1 by value Total revenue
Set background to transparent, add a shape behind, delete category label, add title 'Revenue', and change data format to currency

### Task 6 : Data Slicer

Pick data slicer with Field: year and slicer style:.between 

### Save

Also save the latest version of your Power BI .pbix file and upload it to the Github repository.
You should describe the visuals you created for this page, and add screenshots of how the visuals were set up, and a screenshot of the finished page.
..... need to add pictures 

## Milestone 6

Create a report page for the high level executive summary, to give an overview of the companies performance as a whole.
The report will contain the following visuals:
    - Card visuals showing Total revenue, Total Profits, Total Orders
    - A graph of revenue against time
    - Two donut charts showing orders and revenue by country
    - A bar chart of orders by category
    - KPI's for Quarterly revenue, customers and profits

### Task 1 : Card Visuals

- Copy a card visual from the Customer Detail page and paste it onto the Executive Summary page 3 times
- Assign them to your Total Revenue, Total Orders and Total Profit measures
- Use the Format > Callout Value pane to ensure no more than 2 decimal places in the case of the revenue and profit cards, and only 1 decimal place in the case of the Total Orders measure

### Task 2 : Revenue Line Chart

As with the card visuals, you can copy the line graph from your Customer Detail page, and change it as follows:
- Set Y-axis to Total Revenue

I also changed the title to "Revenue Trending" which I centered and removed the x and y axis titles.
Changed gridlines and made sure the y axis values were in data format currency

### Task 3 : Donut Charts

Add a pair of donut charts, showing Total Revenue broken down by Store[Country] and Store[Store Type] respectively.

I used Store[country code] so I adjusted the title for the chart. I also removed "Total" from the titles of both donut charts and bolded and centered them.


### Task 4 : Bar Chart

Add a bar chart showing number of orders by product category.

Pick the clustered bar chart visual
X-axis field : Total Orders
Y-axis : Product[Category]

Visual
- Remove "Total" form title and centre and bold it
- Remove titles form y and x axes
- remove x axis values
- Remove gridlines
- Turn on data labels and set to one decimal place

### Task 5 : KPI

Create KPIs for Quarterly Revenue, Orders and Profit. To do so we will need to create a set of new measures for the quarterly targets. Create measures for the following:

    - Previous Quarter Profit
        - Previous Quarter Profit = CALCULATE([Total Profit], PREVIOUSQUARTER('Date'[Date]))
    - Previous Quarter Revenue
        - Previous Quarter Revenue = CALCULATE([Total Revenue], PREVIOUSQUARTER('Date'[Date]))
    - Previous Quarter Orders
        - Previous Quarter Orders = CALCULATE([Total Orders], PREVIOUSQUARTER('Date'[Date]))
    - Targets, equal to 5% growth in each measure compared to the previous quarter
        - Target Profit
            - Target Profit = [Previous Quarter Profit] * 1.05
        - Target Revenue
            - Target Revenue = [Previous Quarter Revenue] * 1.05
        - Target Orders
            - Target Orders = [Previous Quarter Orders] * 1.05


For each KPI:
The Value field should be Total '      '
The Trend Axis should be Start of Quarter
The Target should be Target '     '

I was having some trouble with this step as my dates table extended past the latest shipping date of 29 June 2023 to the end of 2023.
........... insert picture of table .............
So i change the date table to end at max shipping date
    - Date = CALENDAR(DATE(2010,1,1), DATE(2023,06,30))

Formatting :
- Changed titles to Quarterly Revenue/Profit/Orders, then centered and bolded it
- Decreseased font size of callout value from 45 to 38 and decimal place to 1
- change target label to 'Previous Quarter' and change font size to 10

### Extra : Top 10 Products Table

.........
- Create a new table, which displays the top 20 products, filtered by orders. 
The table should show each 
    - products description
    - category 
    - revenue
    - customers
    - and number of orders.

Format
- select the column Products[Description], Products[Category], measure [Total revenue], measure [Total Customers] and measure [Total Orders]
    - filter Descriptions by Top 10 by [Total Orders]
    - Rename Description column header to 'Top 10 Products'
- Add conditional formatting to the revenue column, to display data bars for the revenue values
    - go to Format > Cell Element > Total revenue and set data bars to on.
- change total revenue to dispaly values as currency
    - go to Format > Data Format > select Total Revenue > select Currency as Data Format and set decimal place to 2

### Save

## Milestone 7 : Product detail page

This page provides an in-depth look at which products within the inventory are performing well, with the option to filter by product and region.

The report will contain the following visuals:
    - Gauge visuals to show how the selected categories revenue, profit and number of orders are performing against a quarterly target
    - card visuals to show which filters are currently selected
    - An area chart showing relative revenue performance of each category over time
    - A table showing the top 10 products by revenue in the selected context
    - A scatter graph of quantity ordered against profit per item for products in the current context.

### Task 1 : Gauge Visuals

Add a set of three gauges, showing the current-quarter performance of Orders, Revenue and Profit against a quarterly target. The CEO has told you that they are targeting 10% quarter-on-quarter growth in all three metrics.

- In your measures table, define DAX measures:
    -  current-quarter performance of Orders, Revenue and Profit
        - QTD Orders = TOTALQTD([Total Orders], 'Date'[Date])
        - QTD Profit = TOTALQTD([Total Profit], 'Date'[Date])
        - QTD Revenue = TOTALQTD([Total Revenue], 'Date'[Date])
    - quarterly targets for each metric
        - Quarterly Target Orders = CALCULATE(TOTALQTD([Total Orders], 'Date'[Date]) * 1.05, DATEADD('Date'[Date], -1, QUARTER))
        - Quarterly Target Profit = CALCULATE(TOTALQTD([Total Profit], 'Date'[Date]) * 1.05, DATEADD('Date'[Date], -1, QUARTER))
        - Quarterly Target Revenue = CALCULATE(TOTALQTD([Total Revenue], 'Date'[Date]) * 1.05, DATEADD('Date'[Date], -1, QUARTER))
    - gap between target and the performance measures (i.e. Current - Target).
        -
        -
        -
    While defining these measures, in the 'Properties' pane, select the Currency in relation to the relevant measures, and set the Currency Symbol as £.

- Create three gauge filters, and assign the measures you have created. In each case, the maximum value of the gauge should be set to the target, so that the gauge shows as full when the target is met.

- Apply conditional formatting to the callout value (the number in the middle of the gauge), so that it shows as red if the target is not yet met, and black otherwise. You will need to use the gap measures for this. You may use different colours if it first better with your colour scheme.

- Arrange your gauges so that they are evenly spaced along the top of the report, but leave another similarly-sized space for the card visuals that will display which slicer states are currently selected

Format
- make values 10 point font
- chnage titles and center and bold them
- bold callout value and change colour
- add pound signs to callout values for revenue and profit

Task 2 : Filter Cards

To the left of the gauges, we are going to put some placeholder shapes for the cards which will show the filter state. Using a colour in keeping with your theme, add two recatangle shapes, which together take up roughly the same space as one of the gauges.

We will add values to these that will eventually reflect the filter state of the slicers. To do this, we need to define the following measures:
    - Category Selection = IF(ISFILTERED(Products[Category]), SELECTEDVALUE(Products[Category], "No Selection"))
    - Country Selection = IF(ISFILTERED(Stores[Country]), SELECTEDVALUE(Stores[Country],"No Selection"))

Now add a card visual to each of the rectangles, and one of these measures to each of them. Format the card visuals so that they are the same size as the gauges, and the text is centered.
- reduce text size to 18

### Task 3 : Area Chart

We now want to add an area chart that shows how the different product categories are performing in terms of revenue over time.

Add a new area chart, and apply the following fields:
    - X axis should be Dates[Start of Quarter]
    - Y axis values should be Total Revenue
    - Legend should be Products[Category]

Format
    - Remove axis titles
    - data format for revenue as currency

Arrange it on the left of the page, extending to level with the start of the second gauge visual.

### Task 4 : Top Products Table

Add a top 10 products table underneath the area chart. 
The table should have the following fields:
    - Product Description
    - Category
    - Total Revenue
    - Total Customers
    - Total Orders
    - Profit per Order ????

Format
- filter Descriptions by Top 10 by [Total Orders]
    - Rename Description column header to 'Top 10 Products'
- Add conditional formatting to the revenue column, to display data bars for the revenue values
    - go to Format > Cell Element > Total revenue and set data bars to on.
- change total revenue to dispaly values as currency
    - go to Format > Data Format > select Total Revenue > select Currency as Data Format and set decimal place to 2

Task 5 : Scatter Graph

The products team want to know which items to suggest to the marketing team for a promotional campaign. They want a visual that allows them to quickly see which product ranges are both top-selling items and also profitable.
A scatter graph would be ideal for this job.

Create a new calculated column called [Profit per Item] in your Products table, using a DAX formula to work out the profit per item
    - Profit per Item = Products[Sale Price] - Products[Cost Price]

Add a new Scatter chart to the page, and configure it as follows:
    - Values should be Products[Description]
    - X-Axis should be Products[Profit per Item]
    - Y-Axis should be Orders[Total Quantity]
    - Legend should be Products[Category]

### Slicer

- deleted slicer header and added a title instead for both which i bolded
- decreased font of values from 12 to 10
- made bachround transparent
- change padding in values from 4px to 2px

.......................... add stuff here

### Additional cards

I have also added to additional cards as shown in the example layout for most ordered product and highest revenue product.

### Interactions

Ive made it so the category data slicer doesnt interact with the area chart but that the country ne still does

### SAVE

## Milestone 8 : Stores Map Page

A page that can be used to easily see which stores are most profitable, as well as which are on track to reach their quarterly revenue and profit targets.

### Task 1 : Map Visual

On the Stores Map page, add a new map visual. 
It should take up the majority of the page, just leaving a narrow band at the top of the page for a slicer. 
Set the style to your satisfaction in the Format pane, and make sure Show Labels is set to On.

Set the controls of your map as follows:
    - Auto-Zoom: On
    - Zoom buttons: Off
    - Lasso button: Off

Assign your Geography hierarchy to the Location field, and ProfitYTD to the Bubble size field

format
- set data format to currency and 2 decimal place for profit ytd
- turn off title

### Task 2 : Country Slicer

Add a slicer above the map, set the slicer field to Stores[Country], and in the Format section set the slicer style as Tile and the Selection settings to Multi-select with Ctrl/Cmd and Show "Select All" as an option in the slicer.

### Task 3 : Stores Drillthrough Page

To make it easy for the region managers to check on the progress of a given store, we need to create a drillthrough page that summarises each store's performance. 
This will include the following visuals:
    - A table showing the top 5 products based on Total Orders, with columns: Description, Profit YTD, Total Orders, Total Revenue
    - A column chart showing Total Orders by product category for the store
    - Gauges for Profit YTD against a profit target of 20% year-on-year growth vs. the same period in the previous year. The target should use the Target field, not the Maximum Value field, as the target will change as we move through the year.
    - A Card visual showing the currently selected store

#### Stores Drillthrough Page

Create a new page named Stores Drillthrough. Open the format pane and expand the Page information tab. Set the Page type to Drillthrough and set `Drill through when` to Used as category. Set `Drill through from` to country region.

#### measure for visuals

We are going to need some measures for the gauges as follows:
    - Profit YTD and Revenue YTD: You should have already created this earlier in the project
    - Profit Goal and Revenue Goal, which should be a 20% increase on the previous year's year-to-date profit or revenue at the current point in the year
        - Revenue Goal = CALCULATE(TOTALYTD([Total Revenue], 'Date'[Date]) * 1.20, DATEADD('Date'[Date], -1, YEAR))

##### top 5 products table

format
- change profit ytd and total revenue data format to currency and 2 dp

I've currently got it based on Profit YTD not Total Orders

##### column chart

- X-axis : Product Catgory
- Y - axis : Total orders

format
- delete x and y axis titles
- change bar colours

##### Gauges

Value is Profit/Revenue YTD
Target is Profit/Revenue Goal

- change data fromat to currency
- bold callout values
- decrease font size for target, min and max to 10

##### Card

field is calculated column Geography to show region and country

- rename field to Store location and downsize font of callout value
- add border to visual

### Task 4 : Stores Tooltip Page

You want users to be able to see each store's year-to-date profit performance against the profit target just by hovering the mouse over a store on the map. To do this, create a custom tooltip page, and copy over the profit gauge visual, then set the tooltip of the visual to the tooltip page you have created.

- Make new page and call is stores tooltip page
- copy over profit gauge
- copy over georgraphy card and rename to location
- go back to stores map page and on the map visual, got to Fromat > Properties , turn on tooltips and set type to report page and page to stores tooltip page

### SAVE

