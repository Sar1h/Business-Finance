-- Business Finance Database Management System
-- Main.sql - Complete DBMS Implementation

-- Part 1: DDL Operations (Data Definition Language)
-- ----------------------------------------------------

-- Drop database if exists to ensure clean start
DROP DATABASE IF EXISTS bufi_finance;

-- Create database
CREATE DATABASE bufi_finance;
USE bufi_finance;

-- Create Users table (Authentication)
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  full_name VARCHAR(100),
  role ENUM('admin', 'user', 'manager', 'accountant') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Customer Segments table (Lookup table)
CREATE TABLE customer_segments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  segment_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Customers table
CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(20),
  address TEXT,
  segment_id INT,
  business_size ENUM('Small', 'Medium', 'Large', 'Enterprise') NOT NULL,
  acquisition_date DATE,
  lifetime_value DECIMAL(12,2) DEFAULT 0.00,
  status ENUM('Active', 'Inactive', 'Prospect') DEFAULT 'Active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (segment_id) REFERENCES customer_segments(id) ON DELETE SET NULL
);

-- Create Revenue Categories table (Lookup table)
CREATE TABLE revenue_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  parent_category_id INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_category_id) REFERENCES revenue_categories(id) ON DELETE SET NULL
);

-- Create Expense Categories table (Lookup table)
CREATE TABLE expense_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  is_fixed BOOLEAN DEFAULT FALSE,
  parent_category_id INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (parent_category_id) REFERENCES expense_categories(id) ON DELETE SET NULL
);

-- Create Transactions table (Core financial data)
CREATE TABLE transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_date DATE NOT NULL,
  description TEXT,
  amount DECIMAL(12,2) NOT NULL,
  type ENUM('revenue', 'expense') NOT NULL,
  category_id INT,  -- Points to either revenue_categories or expense_categories based on type
  customer_id INT,  -- Can be NULL for expenses
  invoice_number VARCHAR(50) DEFAULT NULL,
  payment_method ENUM('Cash', 'Credit Card', 'Bank Transfer', 'Check', 'Other') DEFAULT NULL,
  recurring BOOLEAN DEFAULT FALSE,
  recurring_frequency ENUM('daily', 'weekly', 'monthly', 'quarterly', 'annually') NULL,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create Sales Stages table for the Sales Funnel (Lookup table)
CREATE TABLE sales_stages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  stage_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  stage_order INT NOT NULL UNIQUE,
  expected_completion_days INT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Sales Funnel Entries table (Pipeline tracking)
CREATE TABLE sales_funnel_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  stage_id INT NOT NULL,
  entry_date DATE NOT NULL,
  exit_date DATE NULL,  -- NULL if still in this stage
  potential_value DECIMAL(12,2) NOT NULL,  -- Potential deal value
  probability DECIMAL(5,2) DEFAULT 0.00,  -- Probability of closing (0-100%)
  converted BOOLEAN DEFAULT FALSE,  -- Whether moved to next stage
  lost_reason TEXT DEFAULT NULL,  -- Reason if deal was lost
  assigned_to INT,  -- User responsible for this deal
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
  FOREIGN KEY (stage_id) REFERENCES sales_stages(id),
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

-- Create Cashflow Projections table (Financial forecasting)
CREATE TABLE cashflow_projections (
  id INT AUTO_INCREMENT PRIMARY KEY,
  projection_date DATE NOT NULL,
  projected_inflow DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  projected_outflow DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  actual_inflow DECIMAL(12,2) DEFAULT NULL,
  actual_outflow DECIMAL(12,2) DEFAULT NULL,
  notes TEXT,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create KPI Metrics table (Performance measurement)
CREATE TABLE kpi_metrics (
  id INT AUTO_INCREMENT PRIMARY KEY,
  metric_name VARCHAR(50) NOT NULL,
  metric_value DECIMAL(12,2) NOT NULL,
  target_value DECIMAL(12,2) NOT NULL,
  metric_date DATE NOT NULL,
  metric_type ENUM('percentage', 'currency', 'number', 'ratio') NOT NULL,
  description TEXT,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create Invoice table (Transaction details)
CREATE TABLE invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  customer_id INT NOT NULL,
  issue_date DATE NOT NULL,
  due_date DATE NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  status ENUM('Draft', 'Sent', 'Paid', 'Overdue', 'Cancelled') DEFAULT 'Draft',
  notes TEXT,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create Invoice Items table (Line items for invoices)
CREATE TABLE invoice_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT NOT NULL,
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
);

-- Create Audit Log table (For tracking all system changes)
CREATE TABLE audit_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action_type VARCHAR(50) NOT NULL,
  table_name VARCHAR(50) NOT NULL,
  record_id INT NOT NULL,
  change_description TEXT NOT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create Budget table (Financial planning)
CREATE TABLE budgets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  budget_name VARCHAR(100) NOT NULL,
  fiscal_year INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_amount DECIMAL(12,2) NOT NULL,
  status ENUM('Draft', 'Active', 'Closed', 'Archived') DEFAULT 'Draft',
  notes TEXT,
  created_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id),
  UNIQUE KEY (budget_name, fiscal_year)
);

-- Create Budget Items table (Line items for budgets)
CREATE TABLE budget_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  budget_id INT NOT NULL,
  category_id INT NOT NULL,
  category_type ENUM('revenue', 'expense') NOT NULL,
  planned_amount DECIMAL(12,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE,
  UNIQUE KEY (budget_id, category_id, category_type)
);

-- Index creation for performance optimization
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_customer ON transactions(customer_id);
CREATE INDEX idx_customers_segment ON customers(segment_id);
CREATE INDEX idx_customers_business_size ON customers(business_size);
CREATE INDEX idx_sales_funnel_stage ON sales_funnel_entries(stage_id);
CREATE INDEX idx_sales_funnel_customer ON sales_funnel_entries(customer_id);
CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_cashflow_date ON cashflow_projections(projection_date);
CREATE INDEX idx_kpi_date ON kpi_metrics(metric_date);
CREATE INDEX idx_budget_fiscal_year ON budgets(fiscal_year); 