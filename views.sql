

USE Company;
GO

/*	
Supply View
Create a view that selects the following details of all items (use column aliases as appropriate):
    • All of the columns from the item table
    • The “profit” made from selling the item (item price minus item cost)
    • Details of the item’s primary supplier concatenated into “name (phone, website)” format, 
e.g. “Thingmart (08 2954 2451, http://thing-mart.com.au/)”
*/

CREATE VIEW SupplyView AS
SELECT p.Item_id,
	  p.Item_name,
      p.Description,
      p.Price,
      p.Cost,
      p.Stock,
      p.Supplier_no,
      (p.Price - p.Cost) AS Profit,
      CONCAT(s.Business_name, ' (', s.Phone_no, ', ', s.Web_address, ')') AS SupplierDetails
FROM
    ProductTable p
JOIN
    SupplierTable s ON p.Supplier_no = s.Supplier_no;



GO

--SELECT * FROM SupplyView;

/*
Order View
Create a view that selects the following details of all orders (use column aliases as appropriate):
    • All of the columns from the order table
    • The customer’s first and last name concatenated into a full name (e.g. “John Smith”)
    • The billing address and the delivery address
    • The total price for the order (Calculated as the sum of the price of each ordered item multiplied by its quantity). If the order occurs during a special event, the event discount should also be applied. 
*/
CREATE VIEW OrderView AS
SELECT
    o.Order_no,
    o.OrderDate_Time,
    o.DeliveryAddress_no,
    o.BillingAddress_no,
    o.Customer_no,
    c.First_name + ' ' + c.Last_name AS CustomerFullName,
    da.Address AS DeliveryAddress,
    ba.Address AS BillingAddress,
    SUM((p.Price * od.Quantity) * (1 - ISNULL(e.Discount, 0))) AS TotalPrice
FROM
    OrderTable o
JOIN
    CustomerTable c ON o.Customer_no = c.Customer_no
JOIN
    AddressTable da ON o.DeliveryAddress_no = da.Address_no
JOIN
    AddressTable ba ON o.BillingAddress_no = ba.Address_no
JOIN
    OrderDetailsTable od ON o.Order_no = od.Invoice_no
JOIN
    ProductTable p ON od.Item_id = p.Item_id
LEFT JOIN
    SpecialEventsTable e ON o.OrderDate_Time BETWEEN e.StartDate_Time AND e.EndingDate_Time
GROUP BY
    o.Order_no,
    o.OrderDate_Time,
    o.DeliveryAddress_no,
    o.BillingAddress_no,
    o.Customer_no,
    c.First_name,
    c.Last_name,
    da.Address,
    ba.Address;

--SELECT * FROM OrderView;






GO
/*	If you wish to create additional views to use in the queries which follow, include them in this file. */
CREATE VIEW OrderItemView AS
SELECT
    o.Order_no,
    od.Item_id,
    p.Item_name,
    p.Description,
    od.Quantity,
    (p.Price * (1 - ISNULL(e.Discount, 0))) AS IndividualPrice
FROM
    OrderTable o
JOIN
    OrderDetailsTable od ON o.Order_no = od.Invoice_no
JOIN
    ProductTable p ON od.Item_id = p.Item_id
LEFT JOIN
    SpecialEventsTable e ON o.OrderDate_Time BETWEEN e.StartDate_Time AND e.EndingDate_Time;

--SELECT * FROM OrderItemView;