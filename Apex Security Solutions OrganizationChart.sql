-- Apex Security Solutions - Organization Structure
-- Table represents the organizational hierarchy of Apex Security Solutions

-- Create the organization table
CREATE TABLE apex_org (
    employee_id INTEGER PRIMARY KEY,
    employee_name VARCHAR(50),
    job_title VARCHAR(100),
    supervisor_id INTEGER,
    FOREIGN KEY (supervisor_id) REFERENCES apex_org(employee_id)
);

-- Insert sample data for Apex Security Solutions
INSERT INTO apex_org (employee_id, employee_name, job_title, supervisor_id) VALUES
    (1, 'John Wick', 'CEO', NULL),
    -- VPs report to CEO
    (2, 'Sarah Connor', 'VP Engineering', 1),
    (3, 'John McClane', 'VP Sales', 1),
    (4, 'Lara Croft', 'Executive Assistant', 1),
    -- Engineering Managers report to VP Engineering
    (5, 'Ethan Hunt', 'Engineering Manager - Web', 2),
    (6, 'Ellen Ripley', 'Engineering Manager - Mobile', 2),
    -- Sales Managers report to VP Sales
    (7, 'James Bond', 'Sales Manager - West', 3),
    (8, 'Katniss Everdeen', 'Sales Manager - East', 3);

-- Query to display Apex Security Solutions hierarchy
SELECT 
    apex_org.employee_name as employee,
    apex_org.job_title,
    supervisor.employee_name as reports_to,
    supervisor.job_title as supervisor_title
FROM 
    apex_org
LEFT JOIN 
    apex_org supervisor ON apex_org.supervisor_id = supervisor.employee_id
ORDER BY 
    apex_org.supervisor_id,
    apex_org.employee_id;