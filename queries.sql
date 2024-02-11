
USE Company;

/*	Query 1 – Product Search (2 marks)
Write a query that selects the item ID, item name, price and stock of any items that have a price ending in .99 and have less than 40 left in stock. 
Order the results with the most expensive product first and format the price to include a $ in front.
*/

SELECT
    Item_id,
    Item_name,
    CONCAT('$', CONVERT(VARCHAR, Price, 0)) AS FormattedPrice,
    Stock
FROM
    ProductTable
WHERE
    Price LIKE '%.99' AND Stock < 40
ORDER BY
    Price DESC;





/*	Query 2 – Unpopular Items (2 marks)
Write a query that selects the item ID, item name, stock and primary supplier details concatenated into “name (phone, website)” format of any items that have never been purchased, 
i.e. items that do not appear in the ordered item table.  Order the results by the stock in descending order.
*/

SELECT
    p.Item_id,
    p.Item_name,
    p.Stock,
    CONCAT(s.Business_name, ' (', s.Phone_no, ', ', ISNULL(s.Web_address, ''), ')') AS SupplierDetails
FROM
    ProductTable p
INNER JOIN
    SupplierTable s ON p.Supplier_no = s.Supplier_no
WHERE
    p.Item_id NOT IN (SELECT DISTINCT Item_id FROM OrderDetailsTable)
ORDER BY
    p.Stock DESC;





/*	Query 3 – Special Event Summary (2 marks)
Write a query that concatenates information about orders that occur during special events into a single column with an alias of “event_orders”, as pictured below. 
The results should appear in order of event name 
*/

SELECT
    CONCAT(e.Name,' ',COUNT(o.Order_no),' ',CASE WHEN e.Discount IS NOT NULL THEN e.Discount * 100 ELSE 0 END,'%') AS event_name
FROM
    OrderTable o
RIGHT JOIN
    SpecialEventsTable e ON o.OrderDate_Time BETWEEN e.StartDate_Time AND e.EndingDate_Time
GROUP BY
    e.Name, e.Discount
ORDER BY
    e.Name;





/*	Query 4 – Monthly Orders (3 marks)
Write a query that finds the number of orders made in each year, each Month. The results should show the year, name of the month and number of orders made in that month.
*/

SELECT 
    YEAR(OrderDate_Time) AS Year, 
    DATENAME(MONTH, OrderDate_Time) AS Month,
    COUNT(*) AS NumberOfOrders 
FROM OrderTable 
GROUP BY 
    YEAR(OrderDate_Time), 
    DATENAME(MONTH, OrderDate_Time) 
ORDER BY 
    Year, 
    Month;


/*	Query 5 – Referrals (3 marks)
Write a query that selects the customer ID and full name of any customers who have referred at least 2 other customers. 
Indicate the number of customers they have referred in the results
*/

-- Write Query 5 here
SELECT
    c.Customer_no,
    CONCAT(c.First_name, ' ', c.Last_name) AS full_name,
    COUNT(r.Referrer) AS referred_count
FROM
    CustomerTable c
LEFT JOIN
    CustomerTable r ON c.Customer_no = r.Referrer
GROUP BY
    c.Customer_no, c.First_name, c.Last_name
HAVING
    COUNT(r.Referrer) >= 2;




/*	Query 6 – Items per Customer (3 marks)
Write a query that selects the Customer Id, Full name, and number of items ordered for each customer. Be sure to include customers that have not ordered any items
*/

SELECT
    c.Customer_no,
    CONCAT(c.First_name, ' ', c.Last_name) AS full_name,
    COUNT(o.Order_no) AS items_ordered
FROM
    CustomerTable c
LEFT JOIN
    OrderTable o ON c.Customer_no = o.Customer_no
LEFT JOIN
    OrderDetailsTable od ON o.Order_no = od.Invoice_no
GROUP BY
    c.Customer_no, c.First_name, c.Last_name;





/*	Query 7 – Electronics count (4 marks)
Write a query that selects the order id, total price (including discounts) and the number of “Electronic Gadgets” purchased for each order. 
Do not include orders that don’t have any “Electronic Gadgets”
*/

SELECT
    o.Order_no,
    SUM((p.Price * od.Quantity) * (1 - ISNULL(e.Discount, 0))) AS total_price,
    COUNT(CASE WHEN ca.Category_name = 'Electronic Gadgets' THEN 1 END) AS electronic_gadgets_count
FROM
    OrderTable o
JOIN
    OrderDetailsTable od ON o.Order_no = od.Invoice_no
JOIN
    ProductTable p ON od.Item_id = p.Item_id
JOIN
	ProductCategoryTable pc ON p.Item_id = pc.ItemID
JOIN 
	CategoryTable ca ON pc.CategoryID = ca.Category_id
LEFT JOIN
    SpecialEventsTable e ON o.OrderDate_Time BETWEEN e.StartDate_Time AND e.EndingDate_Time
WHERE
    ca.Category_name = 'Electronic Gadgets'
GROUP BY
    o.Order_no;




/*	Query 8 – Cohabitation (4 marks)
Write a query that selects the customer name and customer address of any customers who have the same “home” address as another customer.
*/

SELECT
    c1.Customer_no AS customer_id_1,
    CONCAT(c1.First_name, ' ', c1.Last_name) AS customer_name_1,
    a1.Address 
FROM
    CustomerTable c1

JOIN OrderTable o1 ON c1.Customer_no = o1.Customer_no 
JOIN AddressTable a1 On o1.DeliveryAddress_no = a1.Address_no





/*	Query 9 – Bulky orders  (4 marks)
Write a query that selects the order ID, delivery address and number of items of any orders containing more than the average number of items per order.  
Remember to take the quantity of ordered items into account.  
Part of this query will involve determining the average number of items per order.  Order the results by the number of items in the order in descending order.
*/

WITH OrderItemCounts AS (
    SELECT
        o.Order_no,
        a.Address AS Delivery_Address,
        SUM(od.Quantity) AS Items_Count,
        ROW_NUMBER() OVER (ORDER BY SUM(od.Quantity) DESC) AS Rank
    FROM
        OrderTable o
        JOIN OrderDetailsTable od ON o.Order_no = od.Invoice_no
        JOIN AddressTable a ON o.DeliveryAddress_no = a.Address_no
    GROUP BY
        o.Order_no, a.Address
),
AverageItemsPerOrder AS (
    SELECT
        AVG(Items_Count) AS Avg_Items_Per_Order
    FROM
        OrderItemCounts
)
SELECT
    oic.Order_no,
    oic.Delivery_Address,
    oic.Items_Count
FROM
    OrderItemCounts oic
    CROSS JOIN AverageItemsPerOrder aipo
WHERE
    oic.Items_Count > aipo.Avg_Items_Per_Order
ORDER BY
    oic.Items_Count DESC;

