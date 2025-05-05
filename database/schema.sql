CREATE DATABASE IF NOT EXISTS bufi_finance;
USE bufi_finance;
-- Bufi Financial Dashboard Database Schema

SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS expense_categories;
DROP TABLE IF EXISTS revenue_categories;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS customer_segments;
DROP TABLE IF EXISTS sales_stages;
DROP TABLE IF EXISTS sales_funnel_entries;
DROP TABLE IF EXISTS cashflow_projections;
DROP TABLE IF EXISTS kpi_metrics;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- Create Users table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  full_name VARCHAR(100),
  role ENUM('admin', 'user') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Customer Segments table
CREATE TABLE customer_segments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  segment_name VARCHAR(50) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Customers table
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100),
  phone VARCHAR(20),
  address TEXT,
  segment_id INT,
  business_size ENUM('Small', 'Medium', 'Large', 'Enterprise') NOT NULL,
  acquisition_date DATE,
  lifetime_value DECIMAL(12,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (segment_id) REFERENCES customer_segments(id) ON DELETE SET NULL
);

-- Create Revenue Categories table
CREATE TABLE revenue_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Expense Categories table
CREATE TABLE expense_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  description TEXT,
  is_fixed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Transactions table
CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_date DATE NOT NULL,
  description TEXT,
  amount DECIMAL(12,2) NOT NULL,
  type ENUM('revenue', 'expense') NOT NULL,
  category_id INT,  -- Points to either revenue_categories or expense_categories based on type
  customer_id INT,  -- Can be NULL for expenses
  recurring BOOLEAN DEFAULT FALSE,
  recurring_frequency ENUM('daily', 'weekly', 'monthly', 'quarterly', 'annually') NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES revenue_categories(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES expense_categories(id) ON DELETE SET NULL
);

-- Create Sales Stages table for the Sales Funnel
CREATE TABLE sales_stages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  stage_name VARCHAR(50) NOT NULL,
  description TEXT,
  stage_order INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sales Funnel Entries table
CREATE TABLE sales_funnel_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  stage_id INT NOT NULL,
  entry_date DATE NOT NULL,
  exit_date DATE NULL,  -- NULL if still in this stage
  value DECIMAL(12,2),  -- Potential deal value
  converted BOOLEAN DEFAULT FALSE,  -- Whether moved to next stage
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  FOREIGN KEY (stage_id) REFERENCES sales_stages(id)
);

-- Create Cashflow Projections table
CREATE TABLE cashflow_projections (
  id INT AUTO_INCREMENT PRIMARY KEY,
  projection_date DATE NOT NULL,
  projected_inflow DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  projected_outflow DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  actual_inflow DECIMAL(12,2) DEFAULT NULL,
  actual_outflow DECIMAL(12,2) DEFAULT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create KPI Metrics table
CREATE TABLE kpi_metrics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  metric_name VARCHAR(50) NOT NULL,
  metric_value DECIMAL(12,2) NOT NULL,
  target_value DECIMAL(12,2) NOT NULL,
  metric_date DATE NOT NULL,
  metric_type ENUM('percentage', 'currency', 'number', 'ratio') NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Index creation for performance optimization
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_customers_segment ON customers(segment_id);
CREATE INDEX idx_sales_funnel_stage ON sales_funnel_entries(stage_id);
CREATE INDEX idx_cashflow_date ON cashflow_projections(projection_date);
CREATE INDEX idx_kpi_date ON kpi_metrics(metric_date);

-- Views demonstrating different types of joins

-- 1. INNER JOIN: Shows only customers with their segments
CREATE VIEW vw_customer_segments AS
SELECT 
    c.id AS customer_id,
    c.name AS customer_name,
    c.business_size,
    cs.segment_name,
    cs.description AS segment_description
FROM customers c
INNER JOIN customer_segments cs ON c.segment_id = cs.id;

-- 2. LEFT JOIN: Shows all transactions with customer info (including expenses without customers)
CREATE VIEW vw_transaction_details AS
SELECT 
    t.id AS transaction_id,
    t.transaction_date,
    t.amount,
    t.type,
    c.name AS customer_name,
    c.business_size
FROM transactions t
LEFT JOIN customers c ON t.customer_id = c.id;

-- 3. RIGHT JOIN: Shows all sales stages with their funnel entries (including stages without entries)
CREATE VIEW vw_sales_stage_analysis AS
SELECT 
    ss.stage_name,
    ss.stage_order,
    sfe.id AS funnel_entry_id,
    sfe.value AS potential_value,
    sfe.converted
FROM sales_funnel_entries sfe
RIGHT JOIN sales_stages ss ON sfe.stage_id = ss.id;

-- 4. Multiple JOIN: Comprehensive sales funnel view
CREATE VIEW vw_sales_funnel_complete AS
SELECT 
    sfe.id AS funnel_entry_id,
    c.name AS customer_name,
    c.business_size,
    cs.segment_name,
    ss.stage_name,
    ss.stage_order,
    sfe.value AS potential_value,
    sfe.entry_date,
    sfe.exit_date,
    sfe.converted
FROM sales_funnel_entries sfe
INNER JOIN sales_stages ss ON sfe.stage_id = ss.id
LEFT JOIN customers c ON sfe.customer_id = c.id
LEFT JOIN customer_segments cs ON c.segment_id = cs.id;

-- 5. LEFT JOIN with Multiple Tables: Revenue Analysis
CREATE VIEW vw_revenue_analysis AS
SELECT 
    t.transaction_date,
    t.amount,
    rc.category_name AS revenue_category,
    c.name AS customer_name,
    cs.segment_name
FROM transactions t
LEFT JOIN revenue_categories rc ON t.category_id = rc.id
LEFT JOIN customers c ON t.customer_id = c.id
LEFT JOIN customer_segments cs ON c.segment_id = cs.id
WHERE t.type = 'revenue';

-- Triggers with Savepoints and Rollbacks

DELIMITER //

-- 1. Trigger to update customer lifetime value when a new revenue transaction is added
CREATE TRIGGER after_revenue_transaction_insert
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK TO before_ltv_update;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error updating customer lifetime value';
    END;

    IF NEW.type = 'revenue' AND NEW.customer_id IS NOT NULL THEN
        SAVEPOINT before_ltv_update;
        
        UPDATE customers 
        SET lifetime_value = COALESCE(lifetime_value, 0) + NEW.amount
        WHERE id = NEW.customer_id;
        
        -- If the lifetime value becomes negative, rollback to savepoint
        IF (SELECT lifetime_value FROM customers WHERE id = NEW.customer_id) < 0 THEN
            ROLLBACK TO before_ltv_update;
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid lifetime value calculation';
        END IF;
    END IF;
END//

-- 2. Trigger to handle sales funnel stage progression
CREATE TRIGGER before_sales_funnel_update
BEFORE UPDATE ON sales_funnel_entries
FOR EACH ROW
BEGIN
    DECLARE current_stage_order INT;
    DECLARE new_stage_order INT;
    
    -- Get stage orders
    SELECT stage_order INTO current_stage_order
    FROM sales_stages
    WHERE id = OLD.stage_id;
    
    SELECT stage_order INTO new_stage_order
    FROM sales_stages
    WHERE id = NEW.stage_id;
    
    -- Ensure proper stage progression
    IF new_stage_order < current_stage_order THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot move to an earlier sales stage';
    END IF;
    
    -- Set exit date for the old stage
    SET NEW.exit_date = CURRENT_DATE();
END//

-- 3. Trigger to validate and handle cashflow projections
CREATE TRIGGER before_cashflow_projection_insert
BEFORE INSERT ON cashflow_projections
FOR EACH ROW
BEGIN
    DECLARE total_projected_inflow DECIMAL(12,2);
    
    -- Calculate total projected inflow for the month
    SELECT COALESCE(SUM(projected_inflow), 0) INTO total_projected_inflow
    FROM cashflow_projections
    WHERE YEAR(projection_date) = YEAR(NEW.projection_date)
    AND MONTH(projection_date) = MONTH(NEW.projection_date);
    
    -- If total projections exceed a reasonable threshold (example: 1,000,000)
    IF (total_projected_inflow + NEW.projected_inflow) > 1000000 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Monthly projection exceeds reasonable threshold';
    END IF;
END//

-- 4. Trigger to maintain transaction integrity with categories
CREATE TRIGGER before_transaction_insert
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE category_exists INT;
    
    IF NEW.type = 'revenue' THEN
        SELECT COUNT(*) INTO category_exists
        FROM revenue_categories
        WHERE id = NEW.category_id;
        
        IF category_exists = 0 AND NEW.category_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid revenue category';
        END IF;
    ELSE
        SELECT COUNT(*) INTO category_exists
        FROM expense_categories
        WHERE id = NEW.category_id;
        
        IF category_exists = 0 AND NEW.category_id IS NOT NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid expense category';
        END IF;
    END IF;
END//

-- 5. Trigger to handle customer segment changes with history
CREATE TRIGGER after_customer_segment_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    IF OLD.segment_id <=> NEW.segment_id THEN
        UPDATE sales_funnel_entries
        SET notes = CONCAT(COALESCE(notes, ''), '\nSegment changed from ', 
                          COALESCE(OLD.segment_id, 'NULL'), ' to ', 
                          COALESCE(NEW.segment_id, 'NULL'))
        WHERE customer_id = NEW.id;
    END IF;
END//

DELIMITER ; 