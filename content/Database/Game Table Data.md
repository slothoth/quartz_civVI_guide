Civ has a lot of data. How much a building costs, how many movement points a unit has, whether it can carry aircraft. This data is defined in an SQL database that is built when you load into the game. If you don't know what an SQL database is, you can imagine it as a series of Excel spreadsheets, which are referred to as tables. Mods use the UpdateDatabase action to execute files with commands to add or edit existing entries in those spreadsheets. That database is then uneditable, though a copy of it is spat out for people to debug their mods.
To ease you in, I have generated a version of the civ database as a series of excel spreadsheets, which you can find in the Database folder. Here is an example of a table visualised:
![[BuildingYieldChanges_CSV.png]]

There are two formats you can write the commands to change the database, XML or SQL. XML is the standard used by Firaxis, but is more basic, and in my opinion, harder to understand. That XML is then translated into SQL code, under the hood. As a custom thing designed by Firaxis, you cannot get any of the code hints, or information about tables that is possible in a code editor using SQL. SQL is a product that has been used for 50+ years at this point, and so there is thousands of tutorials and courses explaining it. SQL can also do more complicated commands. As a result, this guide will use SQL. It can still be useful to be able to read the XML version, so you can examine Firaxis files or other modders. See the[[ XML->SQL]] chapter for more details
In the example mod under the Hello World folder, the main.sql file has these lines:
```sql
INSERT INTO Building_YieldChanges(BuildingType, YieldType, YieldChange) VALUES
('BUILDING_MONUMENT', 'YIELD_FAITH', 5),
('BUILDING_MONUMENT', 'YIELD_GOLD', 20);

UPDATE Building_YieldChanges SET YieldChange = 10 WHERE BuildingType='BUILDING_MONUMENT' AND YieldType = 'YIELD_CULTURE';
```
SQL statements end in a semi colon, so this is two separate commands. The first says, add two entries in the Building_YieldChanges with these values, where each comma separated value in the bracketed section on the INSERT INTO line is the column used for the comma separated value on the two later lines.

While not used in this case, SQL tables will often have default values for certain columns. This means when you are adding rows, if you don't specify a value for those rows, they will be filled with the default.

The second statement is a little more complicated. It is a command to change rows of the database to set the value of a column, YieldChange to 10, but only in rows where the BuildingType column value is equal to 'BUILDING_MONUMENT' and YieldType column value is equal to 'YIELD_CULTURE'. There is sometimes behaviour you might not expect, like if you misspelled 'YIELD_CULTURE' as 'YLIED_CULTURE', it would not change anything. 

There are lots of tables, and the information of we would think of as one object, like BUILDING_MONUMENT is stored across many tables. Also included in this guide is a tool that lets you text search all those tables to find all the places 'BUILDING_MONUMENT' is mentioned, to make this easier. [[TODO]] PACKAGE THAT TOOL, PYTHON/EXE is maybe not ideal.

In your modding journey, you will certainly make syntax errors and mistakes that cause your mod not to work. Don't worry, this is a normal part of development, what matters is being able to quickly understand the cause of your problem, which is where [[Database Debugging]] comes in.

# SQL

## Restrictions
There are certain restrictions that can be set up on the columns of each sheet, like for example for unit strength, it wouldn't make sense if a unit had a strength of "Food", so the sheet is set up to reject any change that causes that to happen, it would only allow number values in that column. So a modder can see they made that mistake and correct the bug. Similarly, you wouldn't want there to be two entries for the Monument Building, as if they had different costs, which one should be used. So a given column is called the "Primary Key", which means that only one row of the table can have that exact value in that column. A Primary key can also be set as the combination of two column values. For example, the yields a building has is defined in the Building_YieldChanges table, having 3 columns, BuildingType, YieldType, and the number YieldChange. If the Primary key was just BuildingType, then you could not specify a building to have both a gold yield, and a faith yield. Instead, the Primary key for each row is the combination of BuildingType and YieldType. So a row with BUILDING_MONUMENT and YIELD_FOOD and a row with BUILDING_MONUMENT and YIELD_GOLD could co-exist in the same table.

## Foreign Keys
Another concept that SQL databases have is Foreign Keys. There is a lot of interconnected data, so for example there are 6 Yields, Food, Production, Gold, Science, Faith and Culture, and these are specified in the Yields table. A Building can have yields attached to it, which is done in the Building_YieldChanges table, having 3 columns, BuildingType, YieldType, and the number YieldChange.

