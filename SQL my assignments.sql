USE classicmodels;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1Q.SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
-- 1.a 
select * from employees;
desc employees;
select employeenumber,lastname,firstname from employees where jobtitle ='Sales Rep' and reportsto = 1102;

-- 1.b
select * from products;
select distinct(ProductLine) from Products where Productline like "%Cars";
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 2Q.CASE STATEMENTS for Segmentation
-- 2.a
select * from customers;
select 
customerNumber,
customerName,
case 
when country in ('USA','Canada') then 'North America'
when country in ('Uk','France','Germany') then 'Europe'
else 'other'
end as CustomerSegment
from customers;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q3. Group By with Aggregation functions and Having clause, Date and Time functions
-- 3.a
select * from orderdetails;
select productCode,
sum(quantityOrdered) as total_ordered 
from orderdetails group by productCode having sum(quantityOrdered) 
order by total_ordered desc limit 10;

-- 3.b
select * from payments;
select monthname(paymentDate) as payment_month,
count(*) as num_payments
from payments group by payment_month having count(*) > 20 order by num_payments desc;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- 4.a
drop table Customers;
create database Customers_Orders;
use Customers_orders;
create table Customers(customer_id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(255) unique,
phone_number varchar(20));

desc customers;
-- 4.b
drop table orders;
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CHECK (total_amount > 0)
);
select * from orders;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q5. JOINS

use classicmodels;
select * from orders;
select * from Customers;
select Customers.country,
count(Orders.CustomerNumber) as order_count
from Customers
join orders on Customers.CustomerNumber = Orders.CustomerNumber
group by Customers.country
order by order_count desc limit 5;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q6. SELF JOIN

use customers_orders;
drop table project;
create table project(EmployeeID int primary key auto_increment,
FullName varchar(50) not null,
Gender Enum('Male', 'Female') not null,
ManagerID int);

desc project;
select * from project;

-- Inserting values into Table
insert into project (FullName,Gender,ManagerID)
values('Pranaya','Male',3),
('Priyanka','Female',1),
('Preety', 'Female',null),
('Anurag','Male',1),
('Sambit','Male',1),
('Rajesh','Male',3),
('Hina','Female',3);
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q7. DDL Commands: Create, Alter, Rename
-- 7.a
create table facility(Facility_ID int,
Name varchar(100),
State varchar(100),
Country varchar(100));
desc facility; 
-- i)
alter table facility
modify column Facility_ID int auto_increment Primary key;
-- ii)
alter table facility add column city varchar(100) not null after name;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q8. Views in SQL

select * from Products;
select * from orders;
select * from orderdetails;
select * from productlines;
-- Creating View 
CREATE VIEW product_category_sales AS
SELECT
    pl.productLine AS productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM
    productlines pl
    JOIN products p ON pl.productLine = p.productLine
    JOIN orderdetails od ON p.productCode = od.productCode
    JOIN orders o ON od.orderNumber = o.orderNumber
GROUP BY
    pl.productLine;
    
SELECT * FROM classicmodels.product_category_sales;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q9. Stored Procedures in SQL with parameters
select * from payments;
select * from Customers;
delimiter //
create definer = `root`@`localhost` procedure `Get_country_payments` (in ipYear int, in ipCountry varchar(20))
begin 
SELECT 
    YEAR(p.paymentDate) AS Year,
    c.country,
    CONCAT(FORMAT(SUM(p.amount)/1000, 0), ' K') AS Total_Amount
FROM
    Customers c
        JOIN
    payments p ON c.customerNumber = p.customerNumber
    where YEAR(p.paymentDate) = ipyear and c.country = ipCountry
GROUP BY 1 , 2;
end // 
delimiter ;

-- Calling Function 
call classicmodels.Get_country_payments(2003, 'France');
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q10. Window functions - Rank, dense_rank, lead and lag
-- 10.a
select * from customers;
select * from orders;

Select c.customerName,
Count(o.orderNumber) as Order_count,
Rank() over (order by count(o.orderNumber) desc) as order_frequency_rnk
from Customers c
join orders o on c.customerNumber = o.customerNumber
group by c.customerName,c.customerName
order by order_count desc;

-- 10.b
select * from customers ;
select * from orders;

SELECT YEAR(orderDate) AS Year , MONTHNAME(orderDate) AS Month , COUNT(orderNumber) AS Total_Orders, 
CONCAT(ROUND(((COUNT(orderNumber) - LAG(count(orderNumber),1) OVER()) / LAG(count(orderNumber), 1) OVER())*100), '%') AS '% YoY Change'
FROM orders
GROUP BY 1 ,2 ;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q11.Subqueries and their applications
use classicmodels;
select * from products;
SELECT productLine, COUNT(*) as productCount
FROM products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM products)
GROUP BY productLine;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q12. ERROR HANDLING in SQL
-- Creating Table 
CREATE TABLE Emp_EH (
    EmpID INT ,
    EmpName VARCHAR(100) not null,
    EmailAddress VARCHAR(100)
);

-- Stored Procedures
DELIMITER //

CREATE PROCEDURE InsertIntoEmp_EH (
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
       SELECT 'Error occurred' AS ErrorMessage;
    END;
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
    END //

DELIMITER ;

select * from emp_eh;

call classicmodels.InsertIntoEmp_EH(578093, 'Jayasree Bagary', 'jayasree4@gmail.com');
call classicmodels.InsertIntoEmp_EH(578093, null , 'jayasree4@gmail.com');
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q13. TRIGGERS
-- Creating table 
 Create Table Emp_BIT (
    Name VARCHAR(100),
    Occupation VARCHAR(100),
    Working_date DATE,
    Working_hours INT
);
select * from Emp_BIT;

-- Creating Trigger
DELIMITER //

CREATE TRIGGER BeforeInsertEmp_BIT
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = -NEW.Working_hours;
    END IF;
END //

DELIMITER ;
drop Trigger Beforeinsertemp_bit ;

-- Inserting Values into Table 
insert into Emp_BIT (Name,Occupation,Working_date,Working_hours) Values 
('Robin','Scientist','2020-10-04',-2),
('Warner','Engineer','2020-10-04',10),
('Peter','Actor','2020-10-04',13),
('Marco','Doctor','2020-10-04',14),
('Brayden','Teacher','2020-10-04',12),
('Antonio','Business','2020-10-04',11);

Select * from Emp_BIT;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
































