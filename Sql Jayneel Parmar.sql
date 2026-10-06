use classicmodels;
-- 1)a)	Fetch the employee number, first name and last name of those employees who are working as Sales Rep reporting to employee with employeenumber 1102 (Refer employee table)



select employeeNumber , firstname , lastname 
from employees
where jobTitle = "Sales Rep" and reportsto = 1102;

-- 1)b)	Show the unique productline values containing the word cars at the end from the products table.

select distinct productline
from products
where productline like "%Cars%";

-- 2). a. Using a CASE statement, segment customers into three categories based on their country:(Refer Customers table)

select * from customers;

select customerNumber,customerName,
case 
when country = "USA" || country = "Canada" then "North America"
when country = "UK"  || country = "France" || country = "Germany" then "Europe"
else "other"
end as "CustomerSegment"
from customers ;


-- Q3. Group By with Aggregation functions and Having clause, Date and Time functions
-- 3) a)a.	Using the OrderDetails table, identify the top 10 products (by productCode) with the highest total order quantity across all orders.

select * from orderdetails;

select productCode ,
sum(quantityOrdered) as TOTAL_ORDER
from orderdetails
group by productCode
order by TOTAL_ORDER desc
limit 10 ;


-- 3)b)b.	Company wants to analyse payment frequency by month. Extract the month name from the payment date to count the total number of payments for each month and include only those months with a payment count exceeding 20. Sort the results by total number of payments in descending order.  (Refer Payments table). 
select * from payments;

select 
monthname(paymentDate) as payment_month,
count(customerNumber) as num_payments 
from payments
group by payment_month
having num_payments > 20 
order by num_payments desc;

-- Q4. CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default

create database Customers_Orders;

use Customers_Orders;

create table Customers
(customer_id int Primary key auto_increment,
first_name VARCHAR(50) not null,
last_name VARCHAR(50) not null,
email VARCHAR(255) unique,
phone_number VARCHAR(20));


create table Orders
(order_id int primary key auto_increment,
customer_id int ,
foreign key(customer_id) references Customers(customer_id),
order_date date ,
total_amount decimal(10,2) check (total_amount >0)
);

-- Q5. JOINS

-- a. List the top 5 countries (by order count) that Classic Models ships to. (Use the Customers and Orders tables)
use classicmodels;

select 
c.country ,
count(o.orderNumber) as Order_Count 
from customers c
inner join 
orders o  on c.customerNumber = o.customerNumber
group by country 
order by order_Count desc
limit 5;

-- Q6. SELF JOIN

create table project
(EmployeeID int primary key auto_increment,
FULLNAME VARCHAR(50) not null ,
Gender   Varchar(20) ,
ManagerID int
);


insert into project (FullName,Gender,ManagerID)
values 
	('Pranaya','Male',3),
    ('Priyanka','Female',1),
    ('Preety','Female',null),
    ('Anurag','Male',1),
    ('Sambit','Male',1),
    ('Rajesh','Male',3),
    ('Hina','Female',3);
    
    
    select 
     p1.FullName as ManagerName,
     p2.Fullname as EmpName
     from project p1
     left join project p2 on p1.EmployeeID = p2.MAnagerId
     where p2.FullName is not null 
     order by p1.FullName asc;
     
     -- Q7. DDL Commands: Create, Alter, Rename
     
     create table Facility
	(Facility_ID int ,
    Name varchar(20),
    State Varchar(50) ,
    Country Varchar(50)
    );
    desc Facility;
    
    alter table Facility 
    modify column Facility_ID int not null primary key auto_increment;
    
    alter table  Facility 
    add column City Varchar(20) not null ;
    
    -- Q8. Views in SQL
    
   create view Product_Category_Sales as 
select 
	pl.productLine as Product_line,
    round(sum(od.quantityOrdered * od.priceEach),2) as Total_Sales,
    count(distinct o.orderNumber) as Number_of_Orders
from productlines pl
inner join products p on pl.productLine = p.productLine
inner join orderdetails od on p.productCode = od.productCode
inner join orders o on od.orderNumber = o.orderNumber
group by pl.productLine ;

select * from Product_Category_Sales;


-- Q9. Stored Procedures in SQL with parameters
-- a)a. Create a stored procedure Get_country_payments which takes in year and country as inputs and gives year wise, country wise total amount as an output. Format the total amount to nearest thousand unit (K)

use classicmodels;
select * from customers;
select * from payments;
/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_country_payments`(in enter_year int , in enter_country varchar(20) )
BEGIN
select year(p.paymentdate),
c.country,
    concat(round( sum(p.amount)/1000, 2)," k") as Total_Amount
from customers c
inner join payments p on p.CustomerNumber = c.CustomerNumber
where year(p.paymentdate) = enter_year and c.country = enter_country
group by year(p.paymentdate),c.country
order by year(p.paymentdate),c.country;
END
*/
call Get_Country_payments(2003,"France");

-- Q10). Window functions - Rank, dense_rank, lead and lag

-- a) Using customers and orders tables, rank the customers based on their order frequency

select * from customers;
select * from orders;

select 
c.customerName,
count(o.orderNumber) as Total_order,
    dense_rank() over(order by count(o.orderNumber) desc) as order_frequency_rnk
    from customers c
    inner join orders o on c.customerNumber = o.customerNumber
    group by customerName;
    
    
    -- b) Calculate year wise, month name wise count of orders and year over year (YoY) percentage change. Format the YoY values in no decimals and show in % sign.
    
    select 
	year(orderdate) as Year,
    monthname(orderdate) as Month,
    count(orderNumber) as Total_Orders,
    concat( round( (count(orderNumber) -LAG(count(orderNumber)) OVER (ORDER BY year(orderdate) asc))/LAG(count(orderNumber)) OVER (ORDER BY year(orderdate) asc)*100,0), "%") as Yoy_change
from orders
group by year(orderdate), monthname(orderdate) ;


-- Q11.Subqueries and their applications

-- a. Find out how many product lines are there for which the buy price value is greater than the average of buy price value. Show the output as product line and its count.
select * from products;
select avg(buyprice) from products;
select productline ,
count(productline) as Total
from products where buyprice > (select avg (buyprice) from products)
group by productline
order by total desc;

-- Q12. ERROR HANDLING in SQL
    /*  Create the table Emp_EH. Below are its fields.
●	EmpID (Primary Key)
●	EmpName
●	EmailAddress
Create a procedure to accept the values for the columns in Emp_EH. Handle the error using exception handling concept. Show the message as “Error occurred” in case of anything wrong.
*/
create table Emp_EH(EmpID int primary key,EmpName varchar(30),EmailAddress varchar(50));

/*
CREATE DEFINER=`root`@`localhost` PROCEDURE `Emp_Eh`(in enter_your_emp_id int, in enter_your_emp_name varchar(100), in enter_your_emailaddress varchar(150))
BEGIN

declare exit handler for 1048 select "Error occured" as message;
declare exit handler for 1062 select "Error occured" as message;

insert into emp_eh(EmpID,EmpName,EmailAddress) values (enter_your_emp_id,enter_your_emp_name,enter_your_emailaddress);

select * from emp_eh;

END
*/
call Emp_Eh(null,"Abhay","r@gmail.com");


create table Emp_BIT
(
	Name varchar(200),
    Occupation varchar(100),
    Working_date date,
    Working_hours int
);


INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);

/* 
create trigger before_insert_trigger
before insert on Emp_BIT for each row
begin
	if new.working_hours<0 then set new.working_hours=0;
    end if;
end */


insert into Emp_BIT values ("Harshemp_bit","Data Scientist","2020-10-04",-2);
select * from Emp_BIT;



    
    
    

