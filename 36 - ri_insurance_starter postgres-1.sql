-- ri_insurance.sql

-- suppose your system supports an insurance company that sells

-- policies to corporate customers.  Each corporate customer has many employees.

-- Each employee has many dependents.  We'll assume that each dependent links to a single

-- employee, and each employee links to a single corporate customer.


-- In PGADMIN create a databaase called insurance



DROP TABLE IF EXISTS dependents;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers
(
customer_id int PRIMARY KEY,
customer_name varchar(30) NOT NULL
);


INSERT into customers
( customer_id, customer_name)
VALUES
(1, 'JP Morgan Chase');

INSERT into customers
( customer_id, customer_name)
VALUES
(2, 'Citigroup');

SELECT * FROM customers;

CREATE TABLE employees
(
employee_id int PRIMARY KEY,
customer_id int NOT NULL,
employee_lastname VARCHAR(30) NOT NULL,
employee_firstname VARCHAR(30) NOT NULL
);

INSERT into employees
( employee_id, customer_id, employee_lastname, employee_firstname)
VALUES
( 1, 1, 'Dimon', 'Jamie');

INSERT into employees
( employee_id, customer_id, employee_lastname, employee_firstname)
VALUES
( 2, 1, 'Lori', 'Beer');

INSERT into employees
( employee_id, customer_id, employee_lastname, employee_firstname)
VALUES
( 3, 2, 'Corbat', 'Michael');

SELECT * FROM employees;

CREATE TABLE dependents
( 
dependent_id int PRIMARY KEY,
employee_id int NOT NULL,
dependent_lastname VARCHAR(30) NOT NULL,
dependent_firstname VARCHAR(30) NOT NULL,
dependent_type VARCHAR(10)
);

INSERT into dependents 
  ( dependent_id, employee_id, dependent_lastname,
   dependent_firstname, dependent_type )
VALUES
  (1, 3, 'Corbat', 'Donna', 'Spouse');
  
INSERT into dependents 
  ( dependent_id, employee_id, dependent_lastname, 
   dependent_firstname, dependent_type )
VALUES
  (2, 3, 'Corbat', 'Donny', 'Child');
  
INSERT into dependents 
  (dependent_id, employee_id, dependent_lastname, 
   dependent_firstname, dependent_type )
VALUES
  (3, 3, 'Corbat', 'Susan', 'Child');
  
INSERT into dependents 
  ( dependent_id, employee_id, dependent_lastname, 
   dependent_firstname, dependent_type )
VALUES
  (4, 2, 'Beer', 'Bill', 'Spouse');

SELECT * FROM dependents;

SELECT customer_name, 
  employee_lastname, employee_firstname, 
  dependent_lastname, dependent_firstname, dependent_type 
FROM customers c 
INNER JOIN employees e      
ON c.customer_id = e.customer_id
INNER JOIN dependents d
ON e.employee_id = d.employee_id
ORDER BY c.customer_name, e.employee_lastname, e.employee_firstname;

select * from customers;
select * from employees;
select * from dependents;

-- Example below
-- Below is a sample referential integrity
CREATE TABLE order_items (
    product_no integer REFERENCES products ON DELETE RESTRICT,
    order_id integer REFERENCES orders ON DELETE CASCADE,
    quantity integer,
    PRIMARY KEY (product_no, order_id)

ALTER TABLE customers 
ADD CONSTRAINT fk_address 
FOREIGN KEY (address_id) 
REFERENCES customer_address (id);

-- default RI
alter table dependents
	add foreign key (employee_id) references employees;
alter table employees
	add foreign key (customer_id) references customers;
	
drop table customers;
-- can't
drop table employees;
-- can't
insert into employees values (9,9,'test','test');
select * from employees;
delete from customers where customer_id = 1;
-- can't
alter table dependents drop constraint dependents_employee_id_fkey;
alter table employees drop constraint employees_customer_id_fkey;

alter table dependents
	add foreign key (employee_id) references employees on delete cascade;
alter table employees
	add foreign key (customer_id) references customers on delete cascade;
	
select * from customers;
delete from customers where customer_id = 1;
-- can
update customers set customer_id = 5 where customer_id = 2;
-- can't
	
alter table dependents drop constraint dependents_employee_id_fkey;
alter table employees drop constraint employees_customer_id_fkey;

alter table dependents
	add foreign key (employee_id) references employees 
	on delete cascade on update cascade;
alter table employees
	add foreign key (customer_id) references customers 
	on delete cascade on update cascade;
	
update customers set customer_id = 5 where customer_id = 2;
	
select * from customers;
select * from employees;