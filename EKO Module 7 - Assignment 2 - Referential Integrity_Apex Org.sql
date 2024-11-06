-- Drop existing tables in correct order
DROP TABLE IF EXISTS employee_skills;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS skills;
DROP TABLE IF EXISTS departments;

-- Create departments table (parent table)
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);



-- Create employees table (formerly apex_org, but simplified)
CREATE TABLE employees (
    employee_id INTEGER PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    dept_id INTEGER,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON UPDATE CASCADE  -- If department ID changes, update all employees
        ON DELETE RESTRICT -- Can't delete department with employees
);

-- Create skills table
CREATE TABLE skills (
    skill_id INTEGER PRIMARY KEY,
    skill_name VARCHAR(50) NOT NULL
);

-- Create employee_skills junction table
CREATE TABLE employee_skills (
    employee_id INTEGER,
    skill_id INTEGER,
    PRIMARY KEY (employee_id, skill_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON DELETE CASCADE, -- If employee deleted, remove their skills
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
        ON DELETE RESTRICT -- Can't delete skills that employees have
);

-- Insert sample data
INSERT INTO departments VALUES
    (1, 'Engineering'),
    (2, 'Sales'),
    (3, 'Marketing');

	Select * from departments

INSERT INTO employees VALUES
    (1, 'John Wick', 1),
    (2, 'Sarah Connor', 1),
    (3, 'John McClane', 2);

	Select * from employees

INSERT INTO skills VALUES
    (1, 'Python'),
    (2, 'SQL'),
    (3, 'Project Management');

		Select * from skills

INSERT INTO employee_skills VALUES
    (1, 1), -- John knows Python
    (1, 2), -- John knows SQL
    (2, 1), -- Sarah knows Python
    (3, 3); -- McClane knows Project Management

	select * from employee_skills
	
--Here's a better query to display the employee skills data in a more readable format:
SELECT 
    e.employee_name AS "Employee",
    s.skill_name AS "Skill"
FROM employee_skills es
JOIN employees e ON es.employee_id = e.employee_id
JOIN skills s ON es.skill_id = s.skill_id
ORDER BY e.employee_name;


-- Demonstration queries

-- 1. Try to delete a department that has employees (should fail)
-- FAILS because: ON DELETE RESTRICT prevents deleting departments that have employees
DELETE FROM departments WHERE dept_id = 1;

-- 2. Update a department ID (should cascade to employees)
-- WORKS because: ON UPDATE CASCADE automatically updates all employees' dept_id
UPDATE departments SET dept_id = 10 WHERE dept_id = 1;

select * from departments
select * from employees

-- 3. Delete an employee (should cascade to employee_skills)
-- WORKS because: ON DELETE CASCADE automatically removes employee's skills
DELETE FROM employees WHERE employee_id = 1;


select * from employees
select * from employee_skills

-- 4. Try to delete a skill that employees have (should fail)
-- FAILS because: ON DELETE RESTRICT prevents deleting skills that employees have
DELETE FROM skills WHERE skill_id = 1;


-- 5, Try to update McClane's employee_id (this should fail)
-- FAILS because: No ON UPDATE CASCADE for employee_id in employee_skills table
UPDATE employees 
SET employee_id = 100 
WHERE employee_id = 3;