-- SME Financial Health Monitoring Dashboard Database Schema and Data
-- This file contains all database queries for setting up the system

-- =============================================
-- Database Creation
-- =============================================
CREATE DATABASE IF NOT EXISTS bufi_finance;
USE bufi_finance;

-- =============================================
-- Table Structure
-- =============================================

-- Revenue Categories Table
CREATE TABLE revenue_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Expense Categories Table
CREATE TABLE expense_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_fixed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers Table
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    business_size ENUM('Small', 'Medium') NOT NULL,
    industry VARCHAR(100),
    acquisition_date DATE,
    lifetime_value DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transactions Table
CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_date DATE NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    type ENUM('revenue', 'expense') NOT NULL,
    category_id INT,
    customer_id INT,
    recurring BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    FOREIGN KEY (category_id) REFERENCES revenue_categories(id)
);

-- KPI Metrics Table
CREATE TABLE kpi_metrics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(10,2) NOT NULL,
    target_value DECIMAL(10,2),
    metric_date DATE NOT NULL,
    metric_type ENUM('percentage', 'currency', 'number') NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales Pipeline Stages Table
CREATE TABLE sales_stages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stage_name VARCHAR(50) NOT NULL,
    stage_order INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sales Pipeline Entries Table
CREATE TABLE sales_funnel_entries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    stage_id INT NOT NULL,
    entry_date DATE NOT NULL,
    exit_date DATE,
    converted BOOLEAN DEFAULT FALSE,
    value DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stage_id) REFERENCES sales_stages(id)
);

-- Cash Flow Projections Table
CREATE TABLE cashflow_projections (
    id INT PRIMARY KEY AUTO_INCREMENT,
    projection_date DATE NOT NULL,
    projected_inflow DECIMAL(10,2) NOT NULL,
    projected_outflow DECIMAL(10,2) NOT NULL,
    actual_inflow DECIMAL(10,2),
    actual_outflow DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================================
-- Sample Data Insertion
-- =============================================

-- Revenue Categories
INSERT INTO revenue_categories (category_name, description) VALUES
('Product Sales', 'Core product revenue'),
('Services', 'Service and maintenance revenue'),
('Custom Solutions', 'Customized client solutions'),
('Spare Parts', 'Spare parts and accessories sales');

-- Expense Categories
INSERT INTO expense_categories (category_name, description, is_fixed) VALUES
('Payroll', 'Employee salaries and wages', true),
('Raw Materials', 'Production materials and supplies', false),
('Overhead', 'Rent, utilities, and maintenance', true),
('Marketing', 'Advertising and promotion', false),
('Operations', 'Day-to-day operational expenses', true);

-- Sample Customers
INSERT INTO customers (name, business_size, industry, acquisition_date) VALUES
('Smith Manufacturing', 'Small', 'Manufacturing', '2023-01-15'),
('Johnson Services', 'Medium', 'Services', '2023-02-01'),
('Tech Solutions Ltd', 'Small', 'Technology', '2023-03-10'),
('Green Energy Co', 'Medium', 'Energy', '2023-04-20'),
('Local Retail Plus', 'Small', 'Retail', '2023-05-05');

-- Transactions (Last 6 months of realistic SME data)
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring) VALUES
-- Revenue transactions
('2024-01-15', 'Product order - Batch A', 8500.00, 'revenue', 1, 1, false),
('2024-02-01', 'Maintenance contract', 2500.00, 'revenue', 2, 2, true),
('2024-02-15', 'Custom solution project', 12000.00, 'revenue', 3, 3, false),
('2024-03-01', 'Spare parts order', 3500.00, 'revenue', 4, 4, false),
('2024-03-15', 'Product order - Batch B', 9000.00, 'revenue', 1, 5, false),
('2024-04-01', 'Service contract renewal', 2500.00, 'revenue', 2, 2, true),
('2024-04-15', 'Custom implementation', 15000.00, 'revenue', 3, 6, false),
('2024-05-01', 'Product order - Batch C', 7500.00, 'revenue', 1, 7, false),
('2024-05-15', 'Spare parts bulk order', 4500.00, 'revenue', 4, 8, false),
('2024-06-01', 'Monthly maintenance', 2500.00, 'revenue', 2, 2, true),

-- Expense transactions
('2024-01-10', 'Monthly payroll', 15000.00, 'expense', 1, NULL, true),
('2024-01-15', 'Raw materials purchase', 5000.00, 'expense', 2, NULL, false),
('2024-02-10', 'Monthly overhead', 3500.00, 'expense', 3, NULL, true),
('2024-02-15', 'Marketing campaign', 2000.00, 'expense', 4, NULL, false),
('2024-03-10', 'Monthly payroll', 15000.00, 'expense', 1, NULL, true),
('2024-03-15', 'Operational supplies', 1500.00, 'expense', 5, NULL, false),
('2024-04-10', 'Raw materials restock', 4500.00, 'expense', 2, NULL, false),
('2024-04-15', 'Monthly overhead', 3500.00, 'expense', 3, NULL, true),
('2024-05-10', 'Monthly payroll', 15000.00, 'expense', 1, NULL, true),
('2024-05-15', 'Equipment maintenance', 2500.00, 'expense', 5, NULL, false);

-- KPI Metrics
INSERT INTO kpi_metrics (metric_name, metric_value, target_value, metric_date, metric_type, description) VALUES
('Monthly Sales Target', 75.5, 100.0, CURRENT_DATE, 'percentage', 'Progress towards monthly revenue goal'),
('Gross Profit Margin', 32.5, 35.0, CURRENT_DATE, 'percentage', 'Gross profit as percentage of revenue'),
('Operating Expenses', 88.3, 85.0, CURRENT_DATE, 'percentage', 'Operating expenses vs budget'),
('Cash Flow Health', 115.2, 100.0, CURRENT_DATE, 'percentage', 'Current cash flow vs projected');

-- Update Customer Lifetime Values
UPDATE customers 
SET lifetime_value = CASE 
    WHEN business_size = 'Small' THEN 5000.00 + (RAND() * 3000)
    WHEN business_size = 'Medium' THEN 15000.00 + (RAND() * 5000)
END
WHERE id IN (SELECT id FROM (SELECT id FROM customers) AS temp_table);

-- Sales Pipeline Stages
INSERT INTO sales_stages (stage_name, stage_order) VALUES
('Initial Contact', 1),
('Requirements', 2),
('Quotation', 3),
('Negotiation', 4),
('Closed', 5);

-- Sales Pipeline Data
INSERT INTO sales_funnel_entries (stage_id, entry_date, exit_date, converted, value) VALUES
(1, DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), true, 5000.00),
(2, DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), true, 8000.00),
(3, DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), true, 12000.00),
(4, DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), true, 15000.00),
(5, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), CURRENT_DATE, true, 18000.00);

-- Cash Flow Projections
INSERT INTO cashflow_projections (projection_date, projected_inflow, projected_outflow, actual_inflow, actual_outflow) VALUES
(DATE_SUB(CURRENT_DATE, INTERVAL 2 MONTH), 35000.00, 25000.00, 37000.00, 24000.00),
(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH), 38000.00, 26000.00, 39000.00, 25500.00),
(CURRENT_DATE, 40000.00, 27000.00, NULL, NULL),
(DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH), 42000.00, 27500.00, NULL, NULL),
(DATE_ADD(CURRENT_DATE, INTERVAL 2 MONTH), 45000.00, 28000.00, NULL, NULL);

-- =============================================
-- Useful Queries for Dashboard
-- =============================================

-- Monthly Revenue Summary
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') as month,
    SUM(amount) as total_revenue
FROM transactions
WHERE type = 'revenue'
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month DESC;

-- Monthly Expense Summary
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') as month,
    SUM(amount) as total_expenses
FROM transactions
WHERE type = 'expense'
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month DESC;

-- Customer Revenue Analysis
SELECT 
    c.name,
    c.business_size,
    COUNT(t.id) as transaction_count,
    SUM(t.amount) as total_revenue
FROM customers c
LEFT JOIN transactions t ON c.id = t.customer_id
WHERE t.type = 'revenue'
GROUP BY c.id
ORDER BY total_revenue DESC;

-- Expense Categories Analysis
SELECT 
    ec.category_name,
    COUNT(t.id) as transaction_count,
    SUM(t.amount) as total_expense,
    ec.is_fixed
FROM expense_categories ec
LEFT JOIN transactions t ON ec.id = t.category_id
WHERE t.type = 'expense'
GROUP BY ec.id
ORDER BY total_expense DESC;

-- Sales Pipeline Analysis
SELECT 
    ss.stage_name,
    COUNT(sf.id) as deals_count,
    SUM(sf.value) as potential_value
FROM sales_stages ss
LEFT JOIN sales_funnel_entries sf ON ss.id = sf.stage_id
GROUP BY ss.id
ORDER BY ss.stage_order; 