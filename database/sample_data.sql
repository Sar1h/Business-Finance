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