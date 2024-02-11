	

/*	Database Creation & Population Script (7 marks)
	Write a script to create the database you designed in Task 1 (incorporating any changes you have made since then).
	Be sure to give your columns the same data types, properties and constraints specified in your data dictionary, and be sure to name tables and columns consistently.
	Include any suitable default values and any necessary/appropriate CHECK or UNIQUE constraints.

	Make sure this script can be run multiple times without resulting in any errors (hint: drop the database if it exists before trying to create it).
	Use/adapt the code at the start of the creation scripts of the sample databases available in the unit materials to implement this.

	See the assignment brief for further information. 
*/



IF DB_ID('Company') IS NOT NULL             
	BEGIN
		PRINT 'Database exists - dropping.';
		
		USE master;		
		ALTER DATABASE [Company] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
		DROP DATABASE [Company];
	END

GO
PRINT 'Creating database.';

CREATE DATABASE [Company];

GO

--  Now that an empty database has been created, we will make it the active one.
--  The table creation statements that follow will therefore be executed on the newly created database.

USE [Company];

GO

-- creation script here
PRINT 'Creating Customer Table ....'

CREATE TABLE CustomerTable (
    Customer_no INT NOT NULL PRIMARY KEY IDENTITY,
    First_name VARCHAR(30) NOT NULL,
    Last_name VARCHAR(30) NOT NULL,
    Email_address VARCHAR(100) NOT NULL CHECK (CHARINDEX('@', Email_address) > 0),
    Password VARCHAR(50) NOT NULL,
    Referrer INT NULL,
    FOREIGN KEY (Referrer) REFERENCES CustomerTable(Customer_no)
);

PRINT 'Creating Address Table ....'

CREATE TABLE AddressTable (
    Address_no INT NOT NULL PRIMARY KEY IDENTITY,
    Customer_no INT NOT NULL,
    FOREIGN KEY (Customer_no) REFERENCES CustomerTable(Customer_no),
    Address_category VARCHAR(20) NOT NULL,
    Address VARCHAR(60) NOT NULL
);


PRINT 'Creating Supplier table...';

CREATE TABLE SupplierTable (
    Supplier_no INT NOT NULL PRIMARY KEY IDENTITY,
    Business_name VARCHAR(200) NOT NULL,
    Phone_no VARCHAR(20) NOT NULL,
    Web_address VARCHAR(1000) NOT NULL
);

PRINT 'Creating  Product table...';

CREATE TABLE ProductTable (
    Item_id INT NOT NULL PRIMARY KEY IDENTITY,
    Item_name VARCHAR(50) NOT NULL,
    Description TEXT NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0.00),
    Cost DECIMAL(10,2) NOT NULL CHECK (Cost >= 0.00),
    Stock INT NOT NULL,
    Supplier_no INT NOT NULL,
    FOREIGN KEY (Supplier_no) REFERENCES SupplierTable(Supplier_no)
);

PRINT 'Creating Category table...';

CREATE TABLE CategoryTable (
    Category_id INT NOT NULL PRIMARY KEY IDENTITY,
    Category_name VARCHAR(30) NOT NULL UNIQUE
);

PRINT 'Creating Order table...';

CREATE TABLE OrderTable (
    Order_no INT NOT NULL PRIMARY KEY IDENTITY,
    OrderDate_Time DATETIME NOT NULL,
    DeliveryAddress_no INT NOT NULL,
    BillingAddress_no INT NOT NULL,
    Customer_no INT NULL,
    FOREIGN KEY (DeliveryAddress_no) REFERENCES AddressTable(Address_no),
    FOREIGN KEY (BillingAddress_no) REFERENCES AddressTable(Address_no),
    FOREIGN KEY (Customer_no) REFERENCES CustomerTable(Customer_no)
);

PRINT 'Creating Order Details table...';
CREATE TABLE OrderDetailsTable (
    Invoice_no INT NOT NULL PRIMARY KEY IDENTITY,
    Item_id INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity >= 1),
    FOREIGN KEY (Invoice_no) REFERENCES OrderDetailsTable(Invoice_no),
    FOREIGN KEY (Item_id) REFERENCES ProductTable(Item_id)
);

PRINT 'Creating Special Event table...';

CREATE TABLE SpecialEventsTable (
    Name VARCHAR(50) NOT NULL PRIMARY KEY,
    StartDate_Time DATETIME NOT NULL,
    EndingDate_Time DATETIME NOT NULL,
    Discount DECIMAL(10, 2) NOT NULL
);

PRINT 'Creting Product Category Table .....'
CREATE TABLE ProductCategoryTable
( CategoryID INT NOT NULL,
  ItemID INT NOT NULL,

  FOREIGN KEY (CategoryID) REFERENCES CategoryTable (Category_id),
  FOREIGN KEY (ItemID) REFERENCES ProductTable (Item_id)
)






/*	Database Population Statements
	Following the SQL statements to create your database and its tables, you must include statements to populate the database with sufficient test data.
	You are only required to populate the database with enough data to make sure that all views and queries return meaningful results.
	
	You can start working on your views and queries and write INSERT statements as needed for testing as you go.
	The final create.sql should be able to create your database and populate it with enough data to make sure that all views and queries return meaningful results.

	Since writing sample data is time-consuming and quite tedious, I have provided data for some of the tables below.
	Adapt the INSERT statements as needed, and write your own INSERT statements for the remaining tables at the end of the file.
*/



/*	The following statement inserts the details of 4 suppliers into a table named "supplier".
    It specifies values for columns named "business_name", "phone" and "website".
	Supplier ID numbers are not specified since it is assumed that an auto-incrementing integer is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO SupplierTable (business_name, Phone_no, Web_address)
VALUES	('Toys and More', '08 9201 5475', 'http://toysnmoredistributors.com.au/'),	-- Supplier 1
		('Merch Wholesale', '06 7544 4512', 'http://buy.msale.com.au/'),			-- Supplier 2
		('Thingmart', '08 2954 2451', 'http://thing-mart.com.au/'),					-- Supplier 3
		('Deal Express', '+86 591 613 8356', 'http://dealexpress.com.cn/');			-- Supplier 4



/*	The following statement inserts the details of 20 items into a table named "item".  Please excuse the dated pop culture references and lame jokes - I originally wrote most of this data in 2014.
    It specifies values for columns named "item_name", "description", "price" (how much the store sells it for), "cost" (how much it costs the store to buy), "stock", and "supplier_id".
	Item ID numbers are not specified since it is assumed that an auto-incrementing integer is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO ProductTable (Item_name, Description, Price, Cost, Stock, Supplier_no)	
VALUES	('Long Brown Leather Trenchcoat', 'Popular with Firefly fans and flashers.  Try to be one of the former, not the latter.', 69.95, 54.00, 15, 2),	-- Item 1  (Category 1)
		('Archer "That''s How You Get Ants" T-Shirt', 'Do you want ants?  Because that''s how you get ants.', 23.50, 10.50, 10, 2),		         			-- Item 2  (Category 1 & 4)
		('Game of Thrones "I See Dead People" T-Shirt', 'Guns don''t kill people; George R. R. Martin kills people.', 34.99, 12.95, 47, 2),		    		-- Item 3  (Category 1 & 4)
		('TF2 Pyro T-Shirt', 'Mmph mphna mprh.  WARNING:  Highly Flammable.', 29.50, 16.00, 4, 2),													-- Item 4  (Category 1 & 5)
		('Aperture Science Jacket', 'As warm and comforting as the companion cube.  That you destroyed.', 44.99, 37.00, 14, 2),						-- Item 5  (Category 1 & 5)
		('NERF Rocket Launcher', 'Like throwing a foam ball, but nerdier.  Will be banned once someone mods it to fire rocks.', 45.00, 40.00, 104, 1),	-- Item 6  (Category 2)
		('Creepy Talking Doll', 'My name is Talky Tina...and you''d better be nice to me!', 66.66, 0.01, 1, 1),										-- Item 7  (Category 2)
		('Doctor Who Sonic Screwdriver TV Remote', 'This actually exists.  How cool is that?', 99.99, 8.65, 84, 4),										-- Item 8  (Category 2, 3 & 4)
		('LEGO Movie LEGO Set', 'I... Think we''ve come full circle now.', 73.60, 62.24, 45, 1),														-- Item 9  (Category 2 & 4)
		('Hawkeye Action Figure', 'Everyone''s least favourite Avenger is just as interesting as an inanimate object.', 12.95, 4.20, 249, 3),			-- Item 10 (Category 2 & 4)
		('Lobster Shaped 8GB USB2 Thumb Drive', 'Why would anyone want this?  At least nobody would steal it, I guess.', 31.25, 3.99, 57, 4),			-- Item 11 (Category 3)
		('650nm Red Laser Pointer', 'Cats are not the only animals that chase laser pointers.  Ducks do too, and it''s adorable.', 85.25, 76.99, 17, 4),	-- Item 12 (Category 3)
		('Bat Signal Night Light', 'Hopefully a man dressed up as Batman does not burst through your bedroom window.', 14.95, 9.99, 8, 4),				-- Item 13 (Category 3 & 4)
		('TARDIS Shaped Alarm Clock', 'Not even time travel would make some students arrive on time for an 8:30am class.', 42.24, 25.15, 26, 1),		-- Item 14 (Category 3 & 4)
		('Breaking Bad "I am the one who knocks" Poster', 'The chemistry must be respected.', 15.50, 5.00, 6, 2),										-- Item 15 (Category 4)
		('Michael Bay Explosions Poster', 'Which movie is it?  Who can even tell?  Explosions!', 8.00, 2.00, 79, 2),										-- Item 16 (Category 4)
		('Baldur''s gate 3 Artbook', 'All your favourite graphical glitches in a limited-edition hardcover book.', 68.99, 37.00, 38, 1),					-- Item 17 (Category 5)
		('Retro Mario Bros. Badge Set', 'Must know the location of all the warp whistles in SMB3 to purchase this item.', 45.50, 23.15, 14, 1),		-- Item 18 (Category 5)
		('Minecraft Coffee Mug', 'Cube shaped and annoying to drink from, but it has a creeper on it.', 22.99, 3.14, 21, 1),								-- Item 19 (Category 5)
		('Pokeball Cushion Set', 'Stuffed with Mareep.  Not the wool;  The whole Mareep.  They''re extinct now.', 50.00, 37.50, 32, 1);				-- Item 20 (Category 5)



/*	The following statement inserts the details of 6 categories into a table named "category".
    It specifies values for a column named "category_name".
	Category ID numbers are not specified since it is assumed that an auto-incrementing integer is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO CategoryTable(Category_name)
VALUES	('Clothing'),					-- Category 1
		('Toys'),						-- Category 2
		('Electronic Gadgets'),			-- Category 3
		('TV and Movie Merchandise'),	-- Category 4
		('Gaming Merchandise'),			-- Category 5
		('Valuable Funko Pops');		-- Category 6 (empty category)
		


/*	The following statement inserts data into a table named "category_item" to place the items into the categories as indicated above.
    It specifies values for columns named "item_id" and "category_id".
	If required, change the table and column names to match those in your database.
*/

INSERT INTO ProductCategoryTable(ItemID, CategoryID)
VALUES	(1, 1),
		(2, 1), (2, 4),
		(3, 1),	(3, 4),			
		(4, 1),	(4, 5),			
		(5, 1),	(5, 5),		
		(6, 2),	
		(7, 2),	
		(8, 2),	(8, 3),	(8, 4),
		(9, 2),	(9, 4),	
		(10, 2), (10, 4),	
		(11, 3),
		(12, 3),
		(13, 3), (13, 4),
		(14, 3), (14, 4),
		(15, 4),
		(16, 4),
		(17, 4),
		(18, 5),
		(19, 5),
		(20, 5);



-- Write your INSERT statements for the remaining tables here

--Insert Data to Category Table
INSERT INTO CustomerTable (First_name, Last_name, Email_address, Password, Referrer)
VALUES
    ('John', 'Doe', 'john.doe@email.com', 'securepass1', NULL),
    ('Jane', 'Smith', 'jane.smith@email.com', 'mypassword123', 1),
    ('Robert', 'Johnson', 'robert.j@email.com', 'pass1234', 2),
    ('Alice', 'Williams', 'alice@email.com', 'securepass', 1),
    ('Charlie', 'Brown', 'charlie.b@email.com', 'password123', 3),
    ('Emma', 'Davis', 'emma.d@email.com', '1234pass', 4),
    ('Michael', 'Anderson', 'michael@email.com', 'secure123', NULL),
    ('Sophia', 'Taylor', 'sophia.t@email.com', 'pass456', 5),
    ('William', 'White', 'william.w@email.com', 'password789', 6),
    ('Olivia', 'Miller', 'olivia.m@email.com', 'secure789', 7);

--Insert Data to Address Table
INSERT INTO AddressTable (Customer_no, Address_category, Address)
VALUES
    (1, 'Home', '123 Main Street, Cityville'),
    (2, 'Work', '456 Business Avenue, Townsville'),
    (3, 'Home', '789 Residential Lane, Villagetown'),
    (4, 'Work', '987 Corporate Street, Metropolis'),
    (5, 'Home', '456 Family Road, Suburbia'),
    (6, 'Work', '789 Office Park, Downtown'),
    (7, 'Home', '654 Homestead Lane, Countryside'),
    (8, 'Work', '321 Business Tower, City Center'),
    (9, 'Home', '987 Comfort Street, Residential District'),
    (10, 'Work', '123 Corporate Plaza, Uptown');

-- Insert Data To Order Table
INSERT INTO OrderTable (OrderDate_Time, DeliveryAddress_no, BillingAddress_no, Customer_no)
VALUES
    ('2023-06-15 12:00:00', 1, 2, 1),
    ('2023-08-15 15:30:00', 3, 4, 2),
    ('2023-12-15 18:45:00', 5, 6, 3),
    ('2023-03-15 10:15:00', 7, 8, 4),
    ('2023-11-15 13:45:00', 9, 10, 5),
    ('2023-12-01 14:45:00', 1, 2, 6),
    ('2023-12-05 15:30:00', 3, 4, 7),
    ('2023-12-15 11:45:00', 5, 6, 8),
    ('2024-02-09 20:45:00', 7, 8, 9),
    ('2024-02-10 19:00:00', 9, 10, 10);

--Insert Data to Order Details Table
INSERT INTO OrderDetailsTable (Item_id, Quantity)
VALUES
    (1, 5),  (2, 3),  (3, 8),  (4, 2),  (5, 4),
    (5, 10), (7, 1),  (8, 6),  (9, 7),  (10, 15),
    (11, 3), (12, 2), (13, 4), (14, 1), (15, 5),
    (16, 8), (17, 2), (18, 6), (19, 3), (20, 10),
    (1, 5),  (2, 3),  (3, 8),  (4, 2),  (5, 4),
    (8, 10), (7, 1),  (8, 6),  (9, 7),  (10, 15),
    (11, 3), (12, 2), (13, 4), (14, 1), (15, 5),
    (16, 8), (17, 2), (18, 6), (19, 3), (20, 10);


-- Insert Data to Special Event Table
INSERT INTO SpecialEventsTable (Name, StartDate_Time, EndingDate_Time, Discount)
VALUES
    ('Summer Sale', '2023-06-01 00:00:00', '2023-06-30 23:59:59', 0.15),
    ('Back-to-School Promotion', '2023-08-01 00:00:00', '2023-08-31 23:59:59', 0.10),
    ('Holiday Extravaganza', '2023-12-01 00:00:00', '2023-12-31 23:59:59', 0.20),
    ('Spring Clearance', '2023-03-01 00:00:00', '2023-03-31 23:59:59', 0.25),
    ('Black Friday Sale', '2023-11-27 00:00:00', '2023-11-27 23:59:59', 0.30);