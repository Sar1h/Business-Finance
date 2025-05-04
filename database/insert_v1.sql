use bufi_finance;
-- Additional sample data for enhanced analytics

-- Add more customers with different acquisition dates
INSERT INTO customers (name, email, phone, address, segment_id, business_size, acquisition_date, lifetime_value)
VALUES 
('Tech Innovate', 'contact@techinnovate.com', '1234567890', '123 Tech St', 1, 'Small', DATE_SUB(CURRENT_DATE, INTERVAL 2 MONTH), 5000.00),
('Data Corp', 'info@datacorp.com', '2345678901', '456 Data Ave', 2, 'Medium', DATE_SUB(CURRENT_DATE, INTERVAL 4 MONTH), 25000.00),
('AI Solutions', 'sales@aisolutions.com', '3456789012', '789 AI Blvd', 3, 'Enterprise', DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH), 75000.00),
('Cloud Services', 'info@cloudserv.com', '4567890123', '321 Cloud St', 4, 'Small', DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH), 8000.00),
('Big Data Inc', 'contact@bigdata.com', '5678901234', '654 Data St', 3, 'Large', DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH), 50000.00);

-- Add more transactions with recurring flags
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency)
VALUES 
-- Recurring Revenue
('2024-03-01', 'Monthly subscription - Tech Innovate', 1000.00, 'revenue', 3, 11, TRUE, 'monthly'),
('2024-04-01', 'Monthly subscription - Tech Innovate', 1000.00, 'revenue', 3, 11, TRUE, 'monthly'),
('2024-05-01', 'Monthly subscription - Tech Innovate', 1000.00, 'revenue', 3, 11, TRUE, 'monthly'),
('2024-03-15', 'Quarterly service - Data Corp', 5000.00, 'revenue', 2, 12, TRUE, 'quarterly'),
('2024-04-15', 'Custom development - AI Solutions', 15000.00, 'revenue', 1, 13, FALSE, NULL),
('2024-05-15', 'Cloud hosting - Cloud Services', 2000.00, 'revenue', 3, 14, TRUE, 'monthly'),
('2024-03-20', 'Enterprise license - Big Data Inc', 20000.00, 'revenue', 5, 15, TRUE, 'annually'),

-- Additional Expenses
('2024-03-01', 'Cloud infrastructure - March', 3000.00, 'expense', 7, NULL, TRUE, 'monthly'),
('2024-04-01', 'Cloud infrastructure - April', 3200.00, 'expense', 7, NULL, TRUE, 'monthly'),
('2024-05-01', 'Cloud infrastructure - May', 3400.00, 'expense', 7, NULL, TRUE, 'monthly'),
('2024-03-15', 'Marketing campaign - Q2', 5000.00, 'expense', 4, NULL, FALSE, NULL),
('2024-04-15', 'Team training', 2500.00, 'expense', 2, NULL, FALSE, NULL),
('2024-05-15', 'New development tools', 1800.00, 'expense', 7, NULL, FALSE, NULL);

-- Add more sales funnel entries
INSERT INTO sales_funnel_entries (customer_id, stage_id, entry_date, exit_date, value, converted, notes)
VALUES 
(11, 1, DATE_SUB(CURRENT_DATE, INTERVAL 45 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 40 DAY), 10000.00, TRUE, 'Inbound lead from website'),
(11, 2, DATE_SUB(CURRENT_DATE, INTERVAL 40 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), 10000.00, TRUE, 'Product demo completed'),
(11, 3, DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), 10000.00, TRUE, 'Proposal accepted'),
(11, 4, DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), 10000.00, TRUE, 'Contract negotiation'),
(11, 5, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), NULL, 10000.00, FALSE, 'Deal closed'),

(12, 1, DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), 25000.00, TRUE, 'Referral lead'),
(12, 2, DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), 25000.00, TRUE, 'Requirements gathered'),
(12, 3, DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), NULL, 25000.00, FALSE, 'Preparing proposal'),

(13, 1, DATE_SUB(CURRENT_DATE, INTERVAL 60 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 45 DAY), 75000.00, TRUE, 'Enterprise lead'),
(13, 2, DATE_SUB(CURRENT_DATE, INTERVAL 45 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), 75000.00, TRUE, 'Multiple demos completed'),
(13, 3, DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), 75000.00, TRUE, 'Proposal phase'),
(13, 4, DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), NULL, 75000.00, FALSE, 'Final negotiations');

-- Update some customer lifetime values based on transactions
UPDATE customers 
SET lifetime_value = (
    SELECT COALESCE(SUM(amount), 0)
    FROM transactions
    WHERE customer_id = customers.id
    AND type = 'revenue'
)
WHERE id IN (11, 12, 13, 14, 15);




-- Sample data for Bufi Financial Dashboard

-- Revenue Categories
INSERT INTO revenue_categories (category_name, description) VALUES
('Product Sales', 'Revenue from product sales'),
('Services', 'Revenue from services rendered'),
('Subscriptions', 'Recurring subscription revenue'),
('Consulting', 'Revenue from consulting services');

-- Expense Categories
INSERT INTO expense_categories (category_name, description, is_fixed) VALUES
('Salaries', 'Employee salaries and wages', true),
('Marketing', 'Marketing and advertising expenses', false),
('Office Rent', 'Office space rental', true),
('Utilities', 'Electricity, water, internet', true),
('Equipment', 'Office equipment and supplies', false);

-- Transactions (Last 6 months of data)
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring) VALUES
-- Revenue transactions
('2024-01-15', 'Product sale - ABC Corp', 15000.00, 'revenue', 1, 1, false),
('2024-02-01', 'Monthly subscription - XYZ Enterprises', 5000.00, 'revenue', 3, 2, true),
('2024-02-15', 'Consulting services - Tech Solutions', 8500.00, 'revenue', 4, 5, false),
('2024-03-01', 'Service contract - Global Industries', 25000.00, 'revenue', 2, 4, true),
('2024-03-15', 'Product sale - Digital Dynamics', 12000.00, 'revenue', 1, 6, false),
('2024-04-01', 'Monthly subscription - Mega Corporation', 7500.00, 'revenue', 3, 7, true),
('2024-04-15', 'Consulting project - Startup Innovators', 6000.00, 'revenue', 4, 3, false),
('2024-05-01', 'Service package - ABC Corp', 18000.00, 'revenue', 2, 1, true),
('2024-05-15', 'Product sale - Innovative Startup', 9500.00, 'revenue', 1, 8, false),
('2024-06-01', 'Monthly subscription - XYZ Enterprises', 5000.00, 'revenue', 3, 2, true),

-- Expense transactions
('2024-01-10', 'Monthly salaries', 25000.00, 'expense', 1, NULL, true),
('2024-01-15', 'Office rent', 5000.00, 'expense', 3, NULL, true),
('2024-02-10', 'Marketing campaign', 8000.00, 'expense', 2, NULL, false),
('2024-02-15', 'Office rent', 5000.00, 'expense', 3, NULL, true),
('2024-03-10', 'Monthly salaries', 25000.00, 'expense', 1, NULL, true),
('2024-03-15', 'Equipment purchase', 3500.00, 'expense', 5, NULL, false),
('2024-04-10', 'Utilities payment', 1500.00, 'expense', 4, NULL, true),
('2024-04-15', 'Office rent', 5000.00, 'expense', 3, NULL, true),
('2024-05-10', 'Monthly salaries', 25000.00, 'expense', 1, NULL, true),
('2024-05-15', 'Marketing materials', 4500.00, 'expense', 2, NULL, false);

-- KPI Metrics (Current metrics)
INSERT INTO kpi_metrics (metric_name, metric_value, target_value, metric_date, metric_type, description) VALUES
('Sales Target', 85.5, 100.0, CURRENT_DATE, 'percentage', 'Progress towards monthly sales target'),
('Customer Retention', 92.3, 95.0, CURRENT_DATE, 'percentage', 'Percentage of customers retained'),
('Profit Margin', 43.5, 45.0, CURRENT_DATE, 'percentage', 'Net profit divided by revenue'),
('ROI', 18.3, 20.0, CURRENT_DATE, 'percentage', 'Return on investment percentage');

-- Customer Segments (Update existing data)
UPDATE customers 
SET lifetime_value = CASE 
    WHEN business_size = 'Small' THEN 15000.00 + (RAND() * 5000)
    WHEN business_size = 'Medium' THEN 45000.00 + (RAND() * 15000)
    WHEN business_size = 'Large' THEN 95000.00 + (RAND() * 25000)
    WHEN business_size = 'Enterprise' THEN 150000.00 + (RAND() * 50000)
END;

-- Sales Funnel Data
INSERT INTO sales_stages (stage_name, stage_order) VALUES
('Lead', 1),
('Qualified', 2),
('Proposal', 3),
('Negotiation', 4),
('Closed', 5);

INSERT INTO sales_funnel_entries (stage_id, entry_date, exit_date, converted, value) VALUES
(1, DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), true, 10000.00),
(2, DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), true, 15000.00),
(3, DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), true, 25000.00),
(4, DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), true, 35000.00),
(5, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), CURRENT_DATE, true, 50000.00);

-- Cashflow Timeline
INSERT INTO cashflow_projections (projection_date, projected_inflow, projected_outflow, actual_inflow, actual_outflow) VALUES
(DATE_SUB(CURRENT_DATE, INTERVAL 2 MONTH), 75000.00, 45000.00, 78000.00, 43000.00),
(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH), 80000.00, 47000.00, 82000.00, 46000.00),
(CURRENT_DATE, 85000.00, 48000.00, NULL, NULL),
(DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH), 90000.00, 49000.00, NULL, NULL),
(DATE_ADD(CURRENT_DATE, INTERVAL 2 MONTH), 95000.00, 50000.00, NULL, NULL);

----

SET SQL_SAFE_UPDATES = 0;

UPDATE customers 
SET lifetime_value = CASE 
    WHEN business_size = 'Small' THEN 15000.00 + (RAND() * 5000)
    WHEN business_size = 'Medium' THEN 45000.00 + (RAND() * 15000)
    WHEN business_size = 'Large' THEN 95000.00 + (RAND() * 25000)
    WHEN business_size = 'Enterprise' THEN 150000.00 + (RAND() * 50000)
END;

SET SQL_SAFE_UPDATES = 1;


---

-- Sample data for SME Financial Health Monitoring Dashboard

-- Revenue Categories (Simplified for typical SME operations)
INSERT INTO revenue_categories (category_name, description) VALUES
('Product Sales', 'Core product revenue'),
('Services', 'Service and maintenance revenue'),
('Custom Solutions', 'Customized client solutions'),
('Spare Parts', 'Spare parts and accessories sales');

-- Expense Categories (Focused on SME operations)
INSERT INTO expense_categories (category_name, description, is_fixed) VALUES
('Payroll', 'Employee salaries and wages', true),
('Raw Materials', 'Production materials and supplies', false),
('Overhead', 'Rent, utilities, and maintenance', true),
('Marketing', 'Advertising and promotion', false),
('Operations', 'Day-to-day operational expenses', true);

-- Transactions (Last 6 months of realistic SME data)
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring) VALUES
-- Revenue transactions (More realistic SME amounts)
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

-- Expense transactions (Realistic SME operational costs)
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

-- KPI Metrics (SME-focused metrics)
INSERT INTO kpi_metrics (metric_name, metric_value, target_value, metric_date, metric_type, description) VALUES
('Monthly Sales Target', 75.5, 100.0, CURRENT_DATE, 'percentage', 'Progress towards monthly revenue goal'),
('Gross Profit Margin', 32.5, 35.0, CURRENT_DATE, 'percentage', 'Gross profit as percentage of revenue'),
('Operating Expenses', 88.3, 85.0, CURRENT_DATE, 'percentage', 'Operating expenses vs budget'),
('Cash Flow Health', 115.2, 100.0, CURRENT_DATE, 'percentage', 'Current cash flow vs projected');

-- Customer Data (Simplified for single SME)
UPDATE customers 
SET lifetime_value = CASE 
    WHEN business_size = 'Small' THEN 5000.00 + (RAND() * 3000)
    WHEN business_size = 'Medium' THEN 15000.00 + (RAND() * 5000)
END
WHERE id IN (SELECT id FROM (SELECT id FROM customers) AS temp_table);

-- Sales Pipeline Stages (SME-appropriate)
INSERT INTO sales_stages (stage_name, stage_order) VALUES
('Initial Contact', 1),
('Requirements', 2),
('Quotation', 3),
('Negotiation', 4),
('Closed', 5);

-- Sales Pipeline Data (Realistic SME amounts)
INSERT INTO sales_funnel_entries (stage_id, entry_date, exit_date, converted, value) VALUES
(1, DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), true, 5000.00),
(2, DATE_SUB(CURRENT_DATE, INTERVAL 25 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), true, 8000.00),
(3, DATE_SUB(CURRENT_DATE, INTERVAL 20 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), true, 12000.00),
(4, DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), true, 15000.00),
(5, DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), CURRENT_DATE, true, 18000.00);

-- Cash Flow Projections (SME-scale amounts)
INSERT INTO cashflow_projections (projection_date, projected_inflow, projected_outflow, actual_inflow, actual_outflow) VALUES
(DATE_SUB(CURRENT_DATE, INTERVAL 2 MONTH), 35000.00, 25000.00, 37000.00, 24000.00),
(DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH), 38000.00, 26000.00, 39000.00, 25500.00),
(CURRENT_DATE, 40000.00, 27000.00, NULL, NULL),
(DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH), 42000.00, 27500.00, NULL, NULL),
(DATE_ADD(CURRENT_DATE, INTERVAL 2 MONTH), 45000.00, 28000.00, NULL, NULL);
