use [Session 2];

--Joins
--1. Get the firstname and lastname of the employees who placed orders between 15th August,1996 and 15th August,1997.

SELECT DISTINCT
	emp.firstName,
	emp.lastName
FROM 
	employee emp
JOIN 
	orders o
ON 
	emp.employeeID = o.employeeID
WHERE
	o.orderDate >= '1996-08-15' 
	AND o.orderDate <= '1997-08-15';

--2. Get the distinct EmployeeIDs who placed orders before 16th October,1996.

SELECT DISTINCT 
	employeeID
FROM 
	orders
WHERE
	orderDate < '1996-10-16';

--3. How many products were ordered in total by all employees between  13th of January,1997 and 16th of April,1997.

SELECT
	SUM(od.quantity) AS total_products
FROM 
	orders o
JOIN
	orderDetails od
ON 
	o.orderID = od.orderID
WHERE
	o.orderDate >= '1997-01-13' 
	AND o.orderDate <= '1997-04-16';

--4.  What is the total quantity of products for which Anne Dodsworth placed orders between  13th of January,1997 and 16th of April,1997.

SELECT 
	SUM(od.quantity) AS total_quantity
FROM
	orders o
JOIN
	orderDetails od
ON
	o.orderID = od.orderID
WHERE
	o.orderDate >='1997-01-13' 
	AND o.orderDate <= '1997-04-16'
	AND o.employeeID = (SELECT 
							employeeID 
						FROM 
							employee 
						WHERE 
							FirstName = 'Anne'
							AND lastName = 'Dodsworth');

--5. How many orders have been placed in total by Robert King

SELECT
	COUNT(o.orderID) AS total_orders
FROM 
	orders o
WHERE
	o.employeeID = (SELECT 
						employeeID 
					FROM 
						employee 
					WHERE 
						FirstName = 'Robert'
						AND lastName = 'King');

--6.  How many products have been ordered by Robert King between 15th August,1996 and 15th August,1997

SELECT
	SUM(od.quantity) AS total_products
FROM 
	employee emp
JOIN
	orders o
ON 
	emp.employeeID = o.employeeID
JOIN
	orderDetails od
ON 
	o.orderID = od.orderID
WHERE
	emp.firstName = 'Robert'
	AND emp.lastName = 'King'
	AND o.orderDate >= '1996-08-15'
	AND o.orderDate <= '1997-08-15';

--7. I want to make a phone call to the employees to wish them on the occasion of Christmas who placed 
--orders between  13th of January,1997 and 16th of April,1997. I want the EmployeeID, Employee Full Name, HomePhone Number.

SELECT DISTINCT
	emp.employeeID,
	CONCAT(emp.firstName, ' ', emp.lastName) AS fullName,
	emp.homePhone
FROM
	employee emp
JOIN
	orders o
ON 
	emp.employeeID = o.employeeID
WHERE 
	o.orderDate >= '1997-01-13' 
	AND o.orderDate <= '1997-04-16';

--8. Which product received the most orders. Get the product's ID and Name and number of orders it received.
SELECT TOP (1) WITH TIES
	p.productID,
	p.productName,
	COUNT(od.orderID) AS total_orders
FROM 
	orderDetails od
JOIN 
	products p
ON
	od.productID = p.productID
GROUP BY
	p.productID,
	p.productName
ORDER BY
	total_orders DESC;
	
--9.Which are the least shipped products. List only  the top 5 from your list.
SELECT TOP (5) WITH TIES
	p.productID,
	p.productName,
	COUNT(od.orderID) AS least_shipped_products
FROM
	products p
LEFT JOIN
	orderDetails od
ON
	p.productID = od.productID
GROUP BY
	p.productID,
	p.productName
ORDER BY
	least_shipped_products ASC;

--10. What is the total price that is to be paid by Laura Callahan for the order placed on 13th of January,1997.
SELECT 
	SUM(od.unitPrice * od.quantity) AS total_price
FROM
	employee emp
JOIN 
	orders o
ON 
	o.employeeID = emp.employeeID
JOIN
	orderDetails od
ON
	o.orderID = od.orderID
WHERE	
	emp.firstName = 'Laura'
	AND emp.lastName = 'Callahan'
	AND o.orderDate = '1997-01-13';

--11.How many number of unique employees placed orders for Gorgonzola Telino or Gnocchi di nonna Alice or Raclette Courdavault or Camembert Pierrot in the 
--month January,1997
SELECT
	COUNT(DISTINCT o.employeeID) AS total_employees
FROM 
	orderDetails od
JOIN 
	orders o
ON 
	od.orderID = o.orderID
JOIN 
	products p
ON 
	od.productID = p.productID
WHERE 
	p.productName IN ('Gorgonzola Telino' , 'Gnocchi di nonna Alice' , 'Raclette Courdavault' ,'Camembert Pierrot')
	AND (YEAR(o.orderDate) = 1997 AND MONTH(o.orderDate) = 1);

--12.What is the full name of the employees who ordered Tofu between 13th of January,1997 and  30th of January,1997.
SELECT DISTINCT
	CONCAT(emp.firstName, ' ', emp.lastName) AS employee_fullName
FROM
	employee emp
JOIN 
	orders o
ON 
	emp.employeeID = o.employeeID
JOIN
	orderDetails od
ON 
	o.orderID = od.orderID
JOIN 
	products p
ON 
	p.productID = od.productID
WHERE 
	p.productName = 'Tofu'
	AND o.orderDate >= '1997-01-13' 
	AND o.orderDate <= '1997-01-30';

--13. What is the age of the employees in days, months and years who placed orders during the month of August. Get employeeID and full name as well.
SELECT DISTINCT
	emp.employeeID,
	CONCAT(emp.firstName, ' ', emp.lastName) AS fullName,
	DATEDIFF(YEAR, emp.birthDate, GETDATE()) 
      - CASE 
            WHEN 
				(MONTH(emp.birthDate) > MONTH(GETDATE())) 
                 OR (MONTH(emp.birthDate) = MONTH(GETDATE()) AND DAY(emp.birthDate) > DAY(GETDATE())) 
            THEN 1 ELSE 0 
        END AS years,

    DATEDIFF(MONTH, DATEADD(YEAR, 
        DATEDIFF(YEAR, emp.birthDate, GETDATE()) 
        - CASE 
            WHEN (MONTH(emp.birthDate) > MONTH(GETDATE())) 
                 OR (MONTH(emp.birthDate) = MONTH(GETDATE()) AND DAY(emp.birthDate) > DAY(GETDATE())) 
            THEN 1 ELSE 0 
          END, emp.birthDate), GETDATE()) % 12 AS months,

    CASE 
        WHEN 
			DAY(GETDATE()) >= DAY(emp.birthDate) 
        THEN 
			DAY(GETDATE()) - DAY(emp.birthDate)
        ELSE 
            DAY(EOMONTH(DATEADD(MONTH, -1, GETDATE()))) 
            - (DAY(emp.birthDate) - DAY(GETDATE()))
    END AS days
FROM
	employee emp
JOIN
	orders o
ON 
	emp.employeeID = o.employeeID
WHERE
	MONTH(o.orderDate) = 8;

--14.Get all the shipper's name and the number of orders they shipped.
SELECT
	s.companyName,
	COUNT(o.orderID) AS total_orders
FROM
	shippers s
JOIN
	orders o
ON 
	s.shipperID = o.shipperID
GROUP BY
	s.companyName;

--15. Get the all shipper's name and the number of products they shipped.
SELECT
	s.companyName,
	SUM(od.quantity) AS total_products
FROM
	shippers s
JOIN
	orders o
ON 
	s.shipperID = o.shipperID
JOIN 
	orderDetails od
ON 
	o.orderID = od.orderID
GROUP BY
	s.companyName;

--16. Which shipper has bagged most orders. Get the shipper's id, name and the number of orders.
SELECT	TOP (1) WITH TIES
	s.shipperID,
	s.companyName,
	COUNT(o.orderID) AS total_orders
FROM 
	shippers s
JOIN
	orders o
ON 
	s.shipperID = o.shipperID
GROUP BY
	s.shipperID,
	s.companyName
ORDER BY
	total_orders DESC;

--17. Which shipper supplied the most number of products between 10th August,1996 and 20th September,1998. Get the shipper's name and the number of products.
SELECT TOP (1) WITH TIES
	s.companyName,
	SUM(od.quantity) AS total_products
FROM
	shippers s
JOIN
	orders o
ON
	s.shipperID = o.shipperID
JOIN
	orderDetails od
ON
	od.orderID = o.orderID
	AND o.orderDate >= '1996-08-10' 
	AND o.orderDate <= '1998-09-20'
GROUP BY
	s.companyName
ORDER BY
	total_products DESC;

--18. Which employee didn't order any product 4th of April 1997.
SELECT 
	CONCAT(emp.firstName, ' ', emp.lastName) AS employee_name
FROM 
	employee emp
LEFT JOIN
	orders o
ON
	emp.employeeID = o.employeeID
	AND o.orderDate = '1997-04-04'
WHERE
	 o.orderID IS NULL;

--19. How many products where shipped to Steven Buchanan.
SELECT
	SUM(od.quantity) AS total_products
FROM
	employee emp
JOIN 
	orders o
ON 
	emp.employeeID = o.employeeID
JOIN
	orderDetails od
ON
	o.orderID = od.orderID
WHERE 
	emp.firstName = 'Steven'
	AND emp.lastName = 'Buchanan';

--20. How many orders where shipped to Michael Suyama by Federal Shipping
SELECT 
	COUNT(o.orderID) AS total_orders
FROM
	employee emp
JOIN
	orders o
ON
	emp.employeeID = o.employeeID
JOIN
	shippers s
ON
	o.shipperID = s.shipperID
WHERE 
	emp.firstName = 'Michael'
	AND emp.lastName = 'Suyama'
	AND s.companyName = 'Federal Shipping';

--21. How many orders are placed for the products supplied from UK and Germany.
SELECT 
	COUNT(DISTINCT od.orderID) AS total_orders
FROM
	suppliers s
JOIN
	products p
ON
	s.supplierID = p.supplierID
JOIN
	orderDetails od
ON
	p.productID = od.productID
WHERE
	s.country IN ('UK', 'Germany');

--22. How much amount Exotic Liquids received due to the order placed for its products in the month of January,1997.
SELECT
	SUM(od.unitPrice * od.quantity) AS total_amount
FROM
	suppliers s
JOIN
	products p
ON
	s.supplierID = p.supplierID
JOIN
	orderDetails od
ON
	p.productID = od.productID
JOIN
	orders o
ON
	od.orderID = o.orderID
WHERE
	s.companyName = 'Exotic Liquids'
	AND (MONTH(o.orderDate) = 1 AND YEAR(o.orderDate) = 1997);

--23. In which days of January, 1997, the supplier Tokyo Traders haven't received any orders.
-- Generate all days in January 1997 and find days with no orders for Tokyo Traders
-- Generate January 1997 dates without using master..spt_values

WITH Numbers AS (
    -- Generate a sequence of integers from 0 to 30 (31 days)
    SELECT TOP (31) 
		ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) -1 AS n
    FROM sys.all_objects  -- Large system table to ensure enough rows
),
JanuaryDates AS (
    SELECT 
		DATEADD(DAY, n, '1997-01-01') AS order_date
    FROM 
		Numbers
),
TokyoOrders AS (
    SELECT DISTINCT 
		o.orderDate AS order_date
    FROM 
		orders o
    JOIN 
		orderDetails od 
    ON 
		o.orderID = od.orderID
    JOIN 
		products p 
    ON 
		od.productID = p.productID
    JOIN 
		suppliers s 
    ON 
		p.supplierID = s.supplierID
    WHERE 
		s.companyName = 'Tokyo Traders'
      AND o.orderDate >= '1997-01-01'
      AND o.orderDate < '1997-02-01'
)
SELECT 
	jd.order_date   AS order_date
FROM 
	JanuaryDates jd
LEFT JOIN 
	TokyoOrders t 
ON 
	jd.order_date = t.order_date
WHERE 
	t.order_date IS NULL
ORDER BY 
	jd.order_date;

--24. Which of the employees did not place any order for the products supplied by Ma Maison in the month of May.

SELECT 
    CONCAT(emp.firstName, ' ', emp.lastName) AS employee_name
FROM 
    employee emp
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM 
			orders o
        JOIN 
			orderDetails od 
		ON 
			o.orderID = od.orderID
        JOIN 
			products p 
		ON 
			od.productID = p.productID
        JOIN 
			suppliers s 
		ON 
			p.supplierID = s.supplierID
        WHERE 
            s.companyName = 'Ma Maison'
            AND MONTH(o.orderDate) = 5
			AND o.employeeID = emp.employeeID
    )
ORDER BY 
    employee_name;


--25. Which shipper shipped the least number of products for the month of September and October,1997 combined.
SELECT TOP (1) WITH TIES
	s.companyName,
	SUM(od.quantity) AS least_number_of_products
FROM
	shippers s
JOIN
	orders o
ON
	s.shipperID = o.shipperID
JOIN
	orderDetails od
ON
	o.orderID = od.orderID
WHERE 
	(MONTH(o.orderDate) = 9 AND YEAR(o.orderDate) = 1997)
	OR (MONTH(o.orderDate) = 10 AND YEAR(o.orderDate) = 1997)
GROUP BY
	s.companyName
ORDER BY
	least_number_of_products ASC;

--26. What are the products that weren't shipped at all in the month of August, 1997.

SELECT 
    p.productName
FROM 
    products p
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM 
			orderDetails od
        JOIN 
			orders o 
         ON 
			od.orderID = o.orderID
        WHERE 
            od.productID = p.productID  -- correlation with outer query
            AND MONTH(o.shippedDate) = 8
            AND YEAR(o.shippedDate) = 1997
    )
ORDER BY 
    p.productName;

--27. What are the products that weren't ordered by each of the employees. List each employee and the products that he didn't order.

SELECT 
    p.productName,
    CONCAT(emp.firstName, ' ', emp.lastName) AS employee_name
FROM 
    employee emp
CROSS JOIN 
    products p
WHERE NOT EXISTS (
    SELECT 1
    FROM 
		orders o
    JOIN 
		orderDetails od 
	ON 
		o.orderID = od.orderID
    WHERE 
        o.employeeID = emp.employeeID
        AND od.productID = p.productID
)
ORDER BY
    employee_name ASC, 
    p.productName ASC;


--28.Who is busiest shipper in the months of April, May and June during the year 1996 and 1997.
SELECT TOP (1) WITH TIES
	s.companyName,
	COUNT(o.orderID) AS total_orders
FROM
	shippers s
JOIN
	orders o
ON 
	s.shipperID = o.shipperID
WHERE 
	(YEAR(o.orderDate) = 1996 OR YEAR(o.orderDate) = 1997)
	AND (MONTH(o.orderDate) = 4 
		OR MONTH(o.orderDate) = 5
		OR MONTH(o.orderDate) = 6)
GROUP BY
	s.companyName
ORDER BY
	total_orders DESC;

--29.Which country supplied the maximum products for all the employees in the year 1997.

SELECT TOP (1) WITH TIES
    s.country,
    SUM(od.quantity) AS total_products_supplied
FROM
    suppliers s
JOIN
    products p 
ON 
	s.supplierID = p.supplierID
JOIN
    orderDetails od 
ON 
	p.productID = od.productID
JOIN
    orders o 
ON 
	od.orderID = o.orderID 
WHERE
    YEAR(o.orderDate) = 1997 
GROUP BY
    s.country
ORDER BY
    total_products_supplied DESC;


--30.What is the average number of days taken by all shippers to ship the product after the order has been placed by the employees.
SELECT
	s.companyName,
	AVG(DATEDIFF(day, o.orderDate, o.shippeddate)) AS avg_days
FROM
	shippers s
JOIN
	orders o
ON
	s.shipperID = o.shipperID
GROUP BY
	s.companyName;

--31. Who is the quickest shipper of all.
SELECT TOP (1) WITH TIES
	s.companyName,
	AVG(DATEDIFF(day, o.orderDate, o.shippedDate)) AS total_days
FROM
	shippers s
JOIN
	orders o
ON
	s.shipperID = o.shipperID
GROUP BY
	s.companyName
ORDER BY 
	total_days ASC;

--32. Which order took the least number of shipping days. Get the orderid, employees full name, number of products, 
--number of days took to ship and shipper company name.
SELECT TOP (1) WITH TIES
	o.orderID,
	CONCAT(emp.firstName,' ', emp.lastName) AS employee_full_name,
	SUM(od.quantity) AS number_of_products,
	DATEDIFF(day, o.orderDate, o.shippedDate) AS total_days,
	s.companyName
FROM
	shippers s
JOIN
	orders o
ON
	s.shipperID = o.shipperID
JOIN
	employee emp
ON
	o.employeeID = emp.employeeID
JOIN
	orderDetails od
ON
	o.orderID = od.orderID
WHERE 
	o.shippedDate IS NOT NULL
GROUP BY
	o.orderID,
	s.companyName,
	o.orderDate, 
	o.shippedDate,
	emp.firstName,
	emp.lastName
ORDER BY 
	total_days ASC;


--UNION
--1.Which orders took the least number and maximum number of shipping days? Get the orderid, employees 
--full name, number of products, number of days taken to ship the product and shipper company name. Use 
--1 and 2 in the final result set to distinguish the 2 orders.

SELECT *
FROM (
    SELECT TOP (1) WITH TIES
        o.orderID,
        CONCAT(emp.firstName, ' ', emp.lastName) AS employee_full_name,
        COUNT(od.quantity) AS number_of_products,
        MIN(DATEDIFF(day, o.orderDate, o.shippedDate)) AS total_days,
        s.companyName,
        1 AS order_type
    FROM 
		shippers s
    JOIN 
		orders o 
	ON 
		s.shipperID = o.shipperID
    JOIN 
		employee emp 
	ON 
		o.employeeID = emp.employeeID
    JOIN 
		orderDetails od 
	ON 
		o.orderID = od.orderID
    WHERE 
		o.shippedDate IS NOT NULL 
    GROUP BY
        o.orderID,
        s.companyName,
        o.orderDate,
        o.shippedDate,
        emp.firstName,
		emp.lastName
    ORDER BY 
		total_days ASC
) AS least_days

UNION

SELECT *
FROM (
    SELECT TOP (1) WITH TIES
        o.orderID,
        CONCAT(emp.firstName, ' ', emp.lastName) AS employee_full_name,
        COUNT(od.quantity) AS number_of_products,
        MAX(DATEDIFF(day, o.orderDate, o.shippedDate)) AS total_days,
        s.companyName,
        2 AS order_type
    FROM 
		shippers s
    JOIN 
		orders o 
	ON 
		s.shipperID = o.shipperID
    JOIN 
		employee emp 
	ON 
		o.employeeID = emp.employeeID
    JOIN 
		orderDetails od 
	ON 
		o.orderID = od.orderID
    WHERE 
		o.shippedDate IS NOT NULL  
    GROUP BY
        o.orderID,
        s.companyName,
        o.orderDate,
        o.shippedDate,
        emp.firstName, 
		emp.lastName
    ORDER BY 
		total_days DESC
) AS max_days

ORDER BY 
	order_type ASC;

	


--2. Which is cheapest and the costliest of products purchased in the second week of October, 1997. Get the 
--product ID, product Name and unit price. Use 1 and 2 in the final result set to distinguish the 2 products.
-- Cheapest product in 2nd week of Oct 1997

SELECT *
FROM (
    SELECT TOP (1) WITH TIES
        p.productID,
        p.productName,
        od.unitPrice,
        1 AS price_type
    FROM 
        orderDetails od
    JOIN 
        orders o ON od.orderID = o.orderID
    JOIN 
        products p ON od.productID = p.productID
    WHERE 
        o.orderDate >= '1997-10-08' 
        AND o.orderDate < '1997-10-15' 
    ORDER BY 
        od.unitPrice ASC
) AS cheapest

UNION

SELECT *
FROM (
    SELECT TOP (1) WITH TIES
        p.productID,
        p.productName,
        od.unitPrice,
        2 AS price_type 
    FROM 
        orderDetails od
    JOIN 
        orders o ON od.orderID = o.orderID
    JOIN 
        products p ON od.productID = p.productID
    WHERE 
        o.orderDate >= '1997-10-08'
        AND o.orderDate < '1997-10-15'
    ORDER BY 
        od.unitPrice DESC
) AS costliest

ORDER BY 
	price_type ASC;


--Case
--1. Find the distinct shippers who are to ship the orders placed by employees with IDs 1, 3, 5, 7
--Show the shipper's name as "Express Speedy" if the shipper's ID is 2 and "United Package" if the shipper's 
--ID is 3 and "Shipping Federal" if the shipper's ID is 1

SELECT DISTINCT 
       CASE 
           WHEN s.shipperID = 2 THEN 'Express Speedy'
           WHEN s.shipperID = 3 THEN 'United Package'
           WHEN s.shipperID = 1 THEN 'Shipping Federal'
           ELSE s.companyName 
       END AS shipperName
FROM 
	orders o
JOIN 
	shippers s 
ON 
	o.shipperID = s.shipperID
WHERE 
	o.employeeID IN (1, 3, 5, 7);

