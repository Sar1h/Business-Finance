create database bufi_finance;
use bufi_finance;
-- Bufi Financial Dashboard Database Schema

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
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
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