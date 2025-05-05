CREATE DATABASE IF NOT EXISTS bufi_finance;
USE bufi_finance;
-- Bufi Financial Dashboard Database Schema - Simplified Version

-- ====================================================
--  DATABASE INITIALIZATION AND CLEANUP
-- ====================================================

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
DROP TABLE IF EXISTS inventory_items;
DROP TABLE IF EXISTS inventory_transactions;
DROP TABLE IF EXISTS tax_obligations;
DROP TABLE IF EXISTS financial_insights;
DROP TABLE IF EXISTS business_goals;

SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================
--  TABLE DEFINITIONS
-- ====================================================

-- Create Users table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  full_name VARCHAR(100),
  role ENUM('admin', 'user', 'financial_advisor', 'investor') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uk_users_credentials UNIQUE (username, email)
);

-- Create Categories table - combined for both revenue and expense
CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  type ENUM('revenue', 'expense') NOT NULL,
  is_recurring BOOLEAN DEFAULT FALSE,
  is_fixed BOOLEAN DEFAULT FALSE,
  is_tax_deductible BOOLEAN DEFAULT FALSE,
  tax_category VARCHAR(50),
  optimization_potential DECIMAL(5,2) DEFAULT 0.00,
  CONSTRAINT uk_category_name_type UNIQUE (category_name, type)
);

-- Create Customer Segments table
CREATE TABLE customer_segments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  segment_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  profitability_score DECIMAL(5,2),
  growth_potential ENUM('Low', 'Medium', 'High')
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
  risk_score DECIMAL(5,2) DEFAULT 50.00,
  last_purchase_date DATE,
  payment_reliability DECIMAL(5,2) DEFAULT 100.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (segment_id) REFERENCES customer_segments(id) ON DELETE SET NULL,
  CONSTRAINT uk_customer_contact UNIQUE (email, phone)
);

-- Create Transactions table (unified for both revenue and expense)
CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_date DATE NOT NULL,
  description TEXT,
  amount DECIMAL(12,2) NOT NULL,
  type ENUM('revenue', 'expense') NOT NULL,
  category_id INT NOT NULL,
  customer_id INT,
  recurring BOOLEAN DEFAULT FALSE,
  recurring_frequency ENUM('daily', 'weekly', 'monthly', 'quarterly', 'annually') NULL,
  tax_relevant BOOLEAN DEFAULT FALSE,
  payment_method VARCHAR(50),
  invoice_id VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  INDEX idx_transaction_date (transaction_date),
  INDEX idx_transaction_type (type),
  INDEX idx_transaction_category (category_id),
  INDEX idx_transaction_customer (customer_id),
  INDEX idx_transaction_type_date (type, transaction_date),
  INDEX idx_transaction_customer_date (customer_id, transaction_date)
);

-- Create Sales Pipeline table (combines sales stages and funnel entries)
CREATE TABLE sales_pipeline (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  stage_name VARCHAR(50) NOT NULL,
  stage_order INT NOT NULL,
  entry_date DATE NOT NULL,
  exit_date DATE NULL,
  value DECIMAL(12,2),
  confidence_score DECIMAL(5,2) DEFAULT 50.00,
  expected_close_date DATE,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
  INDEX idx_pipeline_stage (stage_name, stage_order),
  INDEX idx_pipeline_customer (customer_id, stage_name)
);

-- Create Cashflow table
CREATE TABLE cashflow (
  id INT AUTO_INCREMENT PRIMARY KEY,
  period_date DATE NOT NULL,
  projected_inflow DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  projected_outflow DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  actual_inflow DECIMAL(12,2) DEFAULT NULL,
  actual_outflow DECIMAL(12,2) DEFAULT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uk_cashflow_date UNIQUE (period_date)
);

-- Create Inventory table
CREATE TABLE inventory (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_name VARCHAR(100) NOT NULL,
  sku VARCHAR(50) UNIQUE,
  cost_price DECIMAL(12,2) NOT NULL,
  selling_price DECIMAL(12,2) NOT NULL,
  current_stock INT NOT NULL DEFAULT 0,
  reorder_level INT NOT NULL DEFAULT 10,
  supplier VARCHAR(100),
  last_restock_date DATE,
  CONSTRAINT uk_item_supplier UNIQUE (item_name, supplier)
);

-- Create Financial Insights table (for AI advisor suggestions)
CREATE TABLE financial_insights (
  id INT AUTO_INCREMENT PRIMARY KEY,
  insight_date DATETIME NOT NULL,
  insight_type ENUM('opportunity', 'risk', 'trend', 'recommendation') NOT NULL,
  category VARCHAR(50) NOT NULL,
  title VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  impact_level ENUM('low', 'medium', 'high', 'critical') NOT NULL,
  is_implemented BOOLEAN DEFAULT FALSE,
  implementation_date DATE,
  INDEX idx_insight_date (insight_date),
  INDEX idx_insight_type (insight_type)
);

-- Create Tax Calendar table
CREATE TABLE tax_calendar (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tax_type VARCHAR(50) NOT NULL,
  due_date DATE NOT NULL,
  amount_due DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  is_paid BOOLEAN DEFAULT FALSE,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  CONSTRAINT uk_tax_period UNIQUE (tax_type, period_start, period_end),
  INDEX idx_tax_due_date (due_date),
  INDEX idx_tax_paid (is_paid)
);

-- ====================================================
--  VIEWS FOR BUSINESS INTELLIGENCE
-- ====================================================

-- 1. Financial Health Dashboard View
CREATE VIEW vw_financial_health AS
SELECT 
    YEAR(t.transaction_date) AS year,
    MONTH(t.transaction_date) AS month,
    SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END) AS total_expenses,
    SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE -t.amount END) AS net_profit,
    (SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END) - 
     SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END)) / 
     NULLIF(SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END), 0) * 100 AS profit_margin,
    COUNT(DISTINCT CASE WHEN t.type = 'revenue' THEN t.customer_id END) AS unique_customers,
    SUM(CASE WHEN t.recurring = TRUE AND t.type = 'revenue' THEN t.amount ELSE 0 END) AS recurring_revenue,
    SUM(CASE WHEN t.recurring = TRUE AND t.type = 'expense' THEN t.amount ELSE 0 END) AS fixed_expenses
FROM 
    transactions t
GROUP BY 
    YEAR(t.transaction_date), MONTH(t.transaction_date)
ORDER BY 
    year DESC, month DESC;

-- 2. Cash Flow Analysis View
CREATE VIEW vw_cashflow_analysis AS
SELECT 
    cf.period_date,
    cf.projected_inflow,
    cf.projected_outflow,
    cf.projected_inflow - cf.projected_outflow AS projected_net_cashflow,
    cf.actual_inflow,
    cf.actual_outflow,
    COALESCE(cf.actual_inflow, 0) - COALESCE(cf.actual_outflow, 0) AS actual_net_cashflow,
    CASE 
        WHEN COALESCE(cf.actual_inflow, 0) < cf.projected_inflow THEN 'Under Target'
        WHEN COALESCE(cf.actual_inflow, 0) > cf.projected_inflow THEN 'Over Target'
        ELSE 'On Target'
    END AS inflow_status,
    CASE 
        WHEN COALESCE(cf.actual_outflow, 0) > cf.projected_outflow THEN 'Over Budget'
        WHEN COALESCE(cf.actual_outflow, 0) < cf.projected_outflow THEN 'Under Budget'
        ELSE 'On Budget'
    END AS outflow_status
FROM 
    cashflow cf
ORDER BY 
    cf.period_date;

-- 3. Revenue Intelligence View
CREATE VIEW vw_revenue_analysis AS
SELECT 
    c.name AS customer_name,
    c.business_size,
    cs.segment_name,
    SUM(t.amount) AS total_revenue,
    COUNT(t.id) AS transaction_count,
    MIN(t.transaction_date) AS first_purchase_date,
    MAX(t.transaction_date) AS last_purchase_date,
    SUM(CASE WHEN t.recurring = TRUE THEN t.amount ELSE 0 END) AS recurring_revenue,
    cat.category_name AS primary_revenue_category
FROM 
    transactions t
    INNER JOIN customers c ON t.customer_id = c.id
    LEFT JOIN customer_segments cs ON c.segment_id = cs.id
    LEFT JOIN categories cat ON t.category_id = cat.id
WHERE 
    t.type = 'revenue'
GROUP BY 
    t.customer_id, c.name, c.business_size, cs.segment_name, cat.category_name
ORDER BY 
    total_revenue DESC;

-- 4. Expense Analysis View
CREATE VIEW vw_expense_analysis AS
SELECT 
    cat.category_name,
    cat.is_fixed,
    cat.is_tax_deductible,
    SUM(t.amount) AS total_expense,
    COUNT(t.id) AS transaction_count,
    AVG(t.amount) AS average_expense,
    SUM(CASE 
            WHEN t.transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) THEN t.amount 
            ELSE 0 
        END) AS last_30_days_expense,
    CASE 
        WHEN cat.optimization_potential > 0.7 THEN 'High Savings Potential'
        WHEN cat.optimization_potential > 0.3 THEN 'Medium Savings Potential'
        ELSE 'Low Savings Potential'
    END AS savings_opportunity
FROM 
    transactions t
    INNER JOIN categories cat ON t.category_id = cat.id
WHERE 
    t.type = 'expense' AND cat.type = 'expense'
GROUP BY 
    t.category_id, cat.category_name, cat.is_fixed, cat.is_tax_deductible, cat.optimization_potential
ORDER BY 
    total_expense DESC;

-- 5. Sales Pipeline View
CREATE VIEW vw_sales_pipeline AS
SELECT 
    sp.stage_name,
    sp.stage_order,
    COUNT(sp.id) AS opportunities_count,
    SUM(sp.value) AS total_pipeline_value,
    AVG(sp.confidence_score) AS avg_confidence,
    SUM(sp.value * (sp.confidence_score/100)) AS weighted_pipeline_value
FROM 
    sales_pipeline sp
WHERE 
    sp.exit_date IS NULL
GROUP BY 
    sp.stage_name, sp.stage_order
ORDER BY 
    sp.stage_order;

-- 6. Customer Concentration Risk Analysis
CREATE VIEW vw_customer_concentration_risk AS
SELECT 
    c.id AS customer_id,
    c.name AS customer_name,
    SUM(t.amount) AS customer_revenue,
    (SELECT SUM(amount) FROM transactions WHERE type = 'revenue') AS total_revenue,
    (SUM(t.amount) / (SELECT SUM(amount) FROM transactions WHERE type = 'revenue')) * 100 AS percentage_of_revenue,
    CASE 
        WHEN (SUM(t.amount) / (SELECT SUM(amount) FROM transactions WHERE type = 'revenue')) * 100 > 25 THEN 'High Dependency'
        WHEN (SUM(t.amount) / (SELECT SUM(amount) FROM transactions WHERE type = 'revenue')) * 100 > 10 THEN 'Medium Dependency'
        ELSE 'Low Dependency'
    END AS concentration_risk
FROM 
    transactions t
    JOIN customers c ON t.customer_id = c.id
WHERE 
    t.type = 'revenue'
GROUP BY 
    c.id, c.name
HAVING 
    percentage_of_revenue > 5
ORDER BY 
    percentage_of_revenue DESC;

-- 7. Inventory Status View
CREATE VIEW vw_inventory_status AS
SELECT
    i.item_name,
    i.sku,
    i.current_stock,
    i.reorder_level,
    i.cost_price,
    i.selling_price,
    i.selling_price - i.cost_price AS profit_margin,
    ((i.selling_price - i.cost_price) / i.cost_price * 100) AS margin_percentage,
    i.current_stock * i.cost_price AS inventory_value,
    CASE 
        WHEN i.current_stock <= i.reorder_level THEN 'Reorder Now'
        WHEN i.current_stock <= i.reorder_level * 1.5 THEN 'Low Stock'
        ELSE 'Adequate Stock'
    END AS stock_status
FROM
    inventory i
ORDER BY
    (i.current_stock / i.reorder_level) ASC;

-- ====================================================
--  TRIGGERS FOR BUSINESS LOGIC
-- ====================================================

DELIMITER //

-- 1. Update customer lifetime value when a revenue transaction is added
CREATE TRIGGER update_customer_lifetime_value
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.type = 'revenue' AND NEW.customer_id IS NOT NULL THEN
        -- Update customer lifetime value
        UPDATE customers 
        SET lifetime_value = COALESCE(lifetime_value, 0) + NEW.amount,
            last_purchase_date = NEW.transaction_date
        WHERE id = NEW.customer_id;
        
        -- Generate financial insight if this is a significant transaction
        IF NEW.amount > (
            SELECT AVG(amount) * 2 FROM transactions 
            WHERE customer_id = NEW.customer_id AND type = 'revenue'
        ) THEN
            INSERT INTO financial_insights (
                insight_date, insight_type, category, title, description, impact_level
            )
            VALUES (
                NOW(), 
                'opportunity', 
                'revenue', 
                CONCAT('High value transaction from ', (SELECT name FROM customers WHERE id = NEW.customer_id)),
                CONCAT('Customer made a purchase of $', NEW.amount, ' which is significantly higher than their average. Consider follow-up for repeat business.'),
                'medium'
            );
        END IF;
    END IF;
END//

-- 2. Auto-generate cashflow projections based on recurring transactions
CREATE TRIGGER generate_cashflow_projections
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE projection_month DATE;
    DECLARE months_to_project INT DEFAULT 3; -- Project 3 months ahead
    DECLARE i INT DEFAULT 1;
    
    IF NEW.recurring = TRUE THEN
        -- Start projecting from next month
        SET projection_month = DATE_ADD(DATE_FORMAT(NEW.transaction_date, '%Y-%m-01'), INTERVAL 1 MONTH);
        
        WHILE i <= months_to_project DO
            -- Calculate projection date based on frequency
            CASE NEW.recurring_frequency
                WHEN 'monthly' THEN SET projection_month = DATE_ADD(projection_month, INTERVAL (i-1) MONTH);
                WHEN 'quarterly' THEN SET projection_month = DATE_ADD(projection_month, INTERVAL ((i-1)*3) MONTH);
                WHEN 'annually' THEN SET projection_month = DATE_ADD(projection_month, INTERVAL ((i-1)*12) MONTH);
                ELSE SET projection_month = DATE_ADD(projection_month, INTERVAL (i-1) MONTH);
            END CASE;
            
            -- Insert or update cashflow projection
            INSERT INTO cashflow (
                period_date, 
                projected_inflow, 
                projected_outflow,
                notes
            )
            VALUES (
                projection_month,
                IF(NEW.type = 'revenue', NEW.amount, 0),
                IF(NEW.type = 'expense', NEW.amount, 0),
                CONCAT('Auto-generated from recurring ', NEW.type, ': ', NEW.description)
            )
            ON DUPLICATE KEY UPDATE
                projected_inflow = projected_inflow + IF(NEW.type = 'revenue', NEW.amount, 0),
                projected_outflow = projected_outflow + IF(NEW.type = 'expense', NEW.amount, 0),
                notes = CONCAT(COALESCE(notes, ''), '\nAdded recurring ', NEW.type, ': ', NEW.amount);
            
            SET i = i + 1;
        END WHILE;
    END IF;
END//

-- 3. Detect expense anomalies and generate insights
CREATE TRIGGER detect_expense_anomalies
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE avg_category_expense DECIMAL(12,2);
    DECLARE category_name VARCHAR(50);
    
    IF NEW.type = 'expense' THEN
        -- Get average expense for this category
        SELECT AVG(t.amount), c.category_name
        INTO avg_category_expense, category_name
        FROM transactions t
        JOIN categories c ON t.category_id = c.id
        WHERE t.category_id = NEW.category_id
        AND t.id != NEW.id
        AND t.type = 'expense'
        GROUP BY t.category_id;
        
        -- If this expense is significantly higher than average, generate an insight
        IF NEW.amount > avg_category_expense * 1.5 AND NEW.amount > 100 THEN
            INSERT INTO financial_insights (
                insight_date, insight_type, category, title, description, impact_level
            )
            VALUES (
                NOW(), 
                'risk', 
                'expense', 
                CONCAT('Unusual expense in category: ', category_name),
                CONCAT('Expense of $', NEW.amount, ' is significantly higher than the average of $', 
                       ROUND(avg_category_expense, 2), ' for this category. Review for potential optimization.'),
                'medium'
            );
        END IF;
    END IF;
END//

-- 4. Update tax calendar when tax-relevant transactions are added
CREATE TRIGGER update_tax_calendar
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE tax_period_start DATE;
    DECLARE tax_period_end DATE;
    DECLARE tax_due_date DATE;
    DECLARE tax_rate DECIMAL(5,2);
    
    IF NEW.tax_relevant = TRUE THEN
        -- Set tax period based on the transaction date (quarterly)
        SET tax_period_start = DATE_FORMAT(CONCAT(YEAR(NEW.transaction_date), '-', 
                                         QUARTER(NEW.transaction_date) * 3 - 2, '-01'), '%Y-%m-%d');
        SET tax_period_end = LAST_DAY(DATE_ADD(tax_period_start, INTERVAL 2 MONTH));
        SET tax_due_date = DATE_ADD(tax_period_end, INTERVAL 1 MONTH); -- Due one month after quarter end
        SET tax_rate = 0.15; -- Example tax rate
        
        -- Create or update tax obligation record
        INSERT INTO tax_calendar (
            tax_type, due_date, amount_due, period_start, period_end
        )
        VALUES (
            IF(NEW.type = 'revenue', 'Income Tax', 'VAT/Sales Tax'),
            tax_due_date,
            NEW.amount * tax_rate,
            tax_period_start,
            tax_period_end
        )
        ON DUPLICATE KEY UPDATE
            amount_due = amount_due + (NEW.amount * tax_rate);
    END IF;
END//

-- 5. Update inventory on sales transactions
CREATE TRIGGER update_inventory_on_sale
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE item_id INT;
    DECLARE quantity INT;
    
    -- Only process for expense transactions related to inventory
    IF NEW.type = 'expense' AND EXISTS (
        SELECT 1 FROM categories 
        WHERE id = NEW.category_id AND category_name = 'Inventory Purchase'
    ) THEN
        -- Extract item_id and quantity from description (simplified approach)
        -- In real implementation, you would have a better structure to identify inventory items
        SET item_id = SUBSTRING_INDEX(NEW.description, ':', 1);
        SET quantity = SUBSTRING_INDEX(SUBSTRING_INDEX(NEW.description, ':', 2), ':', -1);
        
        -- Update inventory
        IF item_id IS NOT NULL AND quantity IS NOT NULL THEN
            UPDATE inventory
            SET current_stock = current_stock + quantity,
                last_restock_date = NEW.transaction_date
            WHERE id = item_id;
            
            -- Generate low stock alert if needed
            INSERT INTO financial_insights (
                insight_date, insight_type, category, title, description, impact_level
            )
            SELECT
                NOW(),
                'risk',
                'inventory',
                CONCAT('Low inventory alert: ', item_name),
                CONCAT('Current stock is low. Current stock: ', current_stock, 
                      '. Reorder level: ', reorder_level),
                'high'
            FROM inventory
            WHERE id = item_id AND current_stock <= reorder_level;
        END IF;
    END IF;
END//

DELIMITER ; 