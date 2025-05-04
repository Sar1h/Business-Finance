-- Seed data for Bufi Financial Dashboard

-- Insert sample users
INSERT INTO users (username, password, email, full_name, role)
VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@bufi.com', 'Admin User', 'admin'),
('user1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user1@bufi.com', 'Regular User', 'user');

-- Insert customer segments
INSERT INTO customer_segments (segment_name, description)
VALUES 
('Small Business', 'Companies with less than 50 employees'),
('Mid-Market', 'Companies with 50-500 employees'),
('Enterprise', 'Companies with more than 500 employees'),
('Startup', 'Companies less than 2 years old');

-- Insert customers
INSERT INTO customers (name, email, phone, address, segment_id, business_size, acquisition_date, lifetime_value)
VALUES 
('ABC Corp', 'contact@abccorp.com', '9876543210', '123 Business Ave, Tech City', 1, 'Small', '2023-01-15', 12500.00),
('XYZ Enterprises', 'info@xyzent.com', '8765432109', '456 Corporate Blvd, Commerce Town', 2, 'Medium', '2023-02-20', 45000.00),
('Startup Innovators', 'hello@startupinnovators.com', '7654321098', '789 Venture St, Innovation Valley', 4, 'Small', '2023-03-10', 8500.00),
('Global Industries', 'contact@globalindustries.com', '6543210987', '101 Global Plaza, Big City', 3, 'Enterprise', '2023-01-05', 120000.00),
('Tech Solutions', 'support@techsolutions.com', '5432109876', '202 Solution Ave, Tech Park', 1, 'Small', '2023-04-12', 15000.00),
('Digital Dynamics', 'info@digitaldynamics.com', '4321098765', '303 Digital Drive, Cyber City', 2, 'Medium', '2023-02-28', 35000.00),
('Mega Corporation', 'contact@megacorp.com', '3210987654', '404 Industry Lane, Corporate Hub', 3, 'Large', '2023-01-25', 95000.00),
('Innovative Startup', 'hello@innovative.com', '2109876543', '505 Innovation Road, Startup Valley', 4, 'Small', '2023-03-20', 7500.00),
('Growth Solutions', 'info@growthsolutions.com', '1098765432', '606 Growth Path, Business Park', 2, 'Medium', '2023-04-05', 28000.00),
('Enterprise Systems', 'sales@enterprisesys.com', '9876543210', '707 Enterprise Way, Tech District', 3, 'Enterprise', '2023-01-10', 150000.00);

-- Insert revenue categories
INSERT INTO revenue_categories (category_name, description)
VALUES 
('Product Sales', 'Revenue from selling products'),
('Services', 'Revenue from providing services'),
('Subscriptions', 'Revenue from recurring subscriptions'),
('Consulting', 'Revenue from consulting services'),
('License Fees', 'Revenue from licensing intellectual property');

-- Insert expense categories
INSERT INTO expense_categories (category_name, description, is_fixed)
VALUES 
('Rent', 'Office space rental expenses', TRUE),
('Salaries', 'Employee salaries', TRUE),
('Utilities', 'Electricity, water, internet expenses', TRUE),
('Marketing', 'Advertising and marketing expenses', FALSE),
('Travel', 'Business travel expenses', FALSE),
('Office Supplies', 'Stationery and office supplies', FALSE),
('Software', 'Software licenses and subscriptions', TRUE),
('Equipment', 'Hardware and equipment purchases', FALSE);

-- Insert transactions (last 6 months of data)
-- Revenue transactions
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency)
VALUES 
-- January
('2024-01-05', 'Product sale to ABC Corp', 5000.00, 'revenue', 1, 1, FALSE, NULL),
('2024-01-10', 'Monthly subscription - XYZ Enterprises', 2500.00, 'revenue', 3, 2, TRUE, 'monthly'),
('2024-01-15', 'Consulting services - Global Industries', 7500.00, 'revenue', 4, 4, FALSE, NULL),
('2024-01-20', 'Service package - Tech Solutions', 1800.00, 'revenue', 2, 5, FALSE, NULL),
('2024-01-25', 'License renewal - Mega Corporation', 9000.00, 'revenue', 5, 7, TRUE, 'annually'),

-- February
('2024-02-03', 'Product sale to Digital Dynamics', 4200.00, 'revenue', 1, 6, FALSE, NULL),
('2024-02-10', 'Monthly subscription - XYZ Enterprises', 2500.00, 'revenue', 3, 2, TRUE, 'monthly'),
('2024-02-12', 'Consulting project - Growth Solutions', 5500.00, 'revenue', 4, 9, FALSE, NULL),
('2024-02-18', 'Service package - Innovative Startup', 1200.00, 'revenue', 2, 8, FALSE, NULL),
('2024-02-25', 'Product sale to ABC Corp', 3800.00, 'revenue', 1, 1, FALSE, NULL),

-- March
('2024-03-04', 'Service contract - Enterprise Systems', 12000.00, 'revenue', 2, 10, FALSE, NULL),
('2024-03-10', 'Monthly subscription - XYZ Enterprises', 2500.00, 'revenue', 3, 2, TRUE, 'monthly'),
('2024-03-15', 'Product sale to Tech Solutions', 4500.00, 'revenue', 1, 5, FALSE, NULL),
('2024-03-22', 'Consulting services - Startup Innovators', 3200.00, 'revenue', 4, 3, FALSE, NULL),
('2024-03-28', 'License fee - Digital Dynamics', 6000.00, 'revenue', 5, 6, FALSE, NULL),

-- April
('2024-04-05', 'Product sale to Global Industries', 8500.00, 'revenue', 1, 4, FALSE, NULL),
('2024-04-10', 'Monthly subscription - XYZ Enterprises', 2500.00, 'revenue', 3, 2, TRUE, 'monthly'),
('2024-04-16', 'Service package - Growth Solutions', 3800.00, 'revenue', 2, 9, FALSE, NULL),
('2024-04-21', 'Consulting project - ABC Corp', 4200.00, 'revenue', 4, 1, FALSE, NULL),
('2024-04-27', 'Product sale to Mega Corporation', 7200.00, 'revenue', 1, 7, FALSE, NULL),

-- May
('2024-05-03', 'Service contract - Enterprise Systems', 9500.00, 'revenue', 2, 10, FALSE, NULL),
('2024-05-10', 'Monthly subscription - XYZ Enterprises', 2500.00, 'revenue', 3, 2, TRUE, 'monthly'),
('2024-05-14', 'Product sale to Innovative Startup', 2800.00, 'revenue', 1, 8, FALSE, NULL),
('2024-05-19', 'Consulting services - Digital Dynamics', 5800.00, 'revenue', 4, 6, FALSE, NULL),
('2024-05-25', 'License renewal - Tech Solutions', 4000.00, 'revenue', 5, 5, TRUE, 'annually'),

-- June
('2024-06-02', 'Product sale to Growth Solutions', 6200.00, 'revenue', 1, 9, FALSE, NULL),
('2024-06-09', 'Monthly subscription - XYZ Enterprises', 2500.00, 'revenue', 3, 2, TRUE, 'monthly'),
('2024-06-13', 'Service package - Startup Innovators', 3200.00, 'revenue', 2, 3, FALSE, NULL),
('2024-06-20', 'Consulting project - Mega Corporation', 9800.00, 'revenue', 4, 7, FALSE, NULL),
('2024-06-26', 'Product sale to ABC Corp', 4800.00, 'revenue', 1, 1, FALSE, NULL),
('2024-06-29', 'License fee - Global Industries', 7500.00, 'revenue', 5, 4, FALSE, NULL);

-- Expense transactions
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency)
VALUES 
-- January
('2024-01-01', 'Office rent - January', 2500.00, 'expense', 1, NULL, TRUE, 'monthly'),
('2024-01-05', 'Employee salaries - January', 8500.00, 'expense', 2, NULL, TRUE, 'monthly'),
('2024-01-10', 'Utilities payment', 450.00, 'expense', 3, NULL, TRUE, 'monthly'),
('2024-01-15', 'Digital marketing campaign', 1200.00, 'expense', 4, NULL, FALSE, NULL),
('2024-01-25', 'Software subscriptions', 650.00, 'expense', 7, NULL, TRUE, 'monthly'),

-- February
('2024-02-01', 'Office rent - February', 2500.00, 'expense', 1, NULL, TRUE, 'monthly'),
('2024-02-05', 'Employee salaries - February', 8500.00, 'expense', 2, NULL, TRUE, 'monthly'),
('2024-02-10', 'Utilities payment', 480.00, 'expense', 3, NULL, TRUE, 'monthly'),
('2024-02-18', 'Business trip to client', 1350.00, 'expense', 5, NULL, FALSE, NULL),
('2024-02-25', 'Software subscriptions', 650.00, 'expense', 7, NULL, TRUE, 'monthly'),
('2024-02-27', 'Office supplies restock', 320.00, 'expense', 6, NULL, FALSE, NULL),

-- March
('2024-03-01', 'Office rent - March', 2500.00, 'expense', 1, NULL, TRUE, 'monthly'),
('2024-03-05', 'Employee salaries - March', 8500.00, 'expense', 2, NULL, TRUE, 'monthly'),
('2024-03-10', 'Utilities payment', 460.00, 'expense', 3, NULL, TRUE, 'monthly'),
('2024-03-15', 'Marketing materials', 950.00, 'expense', 4, NULL, FALSE, NULL),
('2024-03-20', 'New laptop for employee', 1200.00, 'expense', 8, NULL, FALSE, NULL),
('2024-03-25', 'Software subscriptions', 650.00, 'expense', 7, NULL, TRUE, 'monthly'),

-- April
('2024-04-01', 'Office rent - April', 2500.00, 'expense', 1, NULL, TRUE, 'monthly'),
('2024-04-05', 'Employee salaries - April', 8500.00, 'expense', 2, NULL, TRUE, 'monthly'),
('2024-04-10', 'Utilities payment', 440.00, 'expense', 3, NULL, TRUE, 'monthly'),
('2024-04-17', 'Digital marketing campaign', 1500.00, 'expense', 4, NULL, FALSE, NULL),
('2024-04-22', 'Business conference attendance', 1800.00, 'expense', 5, NULL, FALSE, NULL),
('2024-04-25', 'Software subscriptions', 650.00, 'expense', 7, NULL, TRUE, 'monthly'),

-- May
('2024-05-01', 'Office rent - May', 2500.00, 'expense', 1, NULL, TRUE, 'monthly'),
('2024-05-05', 'Employee salaries - May', 8500.00, 'expense', 2, NULL, TRUE, 'monthly'),
('2024-05-10', 'Utilities payment', 430.00, 'expense', 3, NULL, TRUE, 'monthly'),
('2024-05-16', 'Office furniture purchase', 1600.00, 'expense', 8, NULL, FALSE, NULL),
('2024-05-20', 'Client entertainment', 850.00, 'expense', 5, NULL, FALSE, NULL),
('2024-05-25', 'Software subscriptions', 650.00, 'expense', 7, NULL, TRUE, 'monthly'),
('2024-05-28', 'Office supplies restock', 280.00, 'expense', 6, NULL, FALSE, NULL),

-- June
('2024-06-01', 'Office rent - June', 2500.00, 'expense', 1, NULL, TRUE, 'monthly'),
('2024-06-05', 'Employee salaries - June', 8500.00, 'expense', 2, NULL, TRUE, 'monthly'),
('2024-06-10', 'Utilities payment', 470.00, 'expense', 3, NULL, TRUE, 'monthly'),
('2024-06-15', 'Marketing campaign for new product', 2200.00, 'expense', 4, NULL, FALSE, NULL),
('2024-06-22', 'New equipment purchase', 1450.00, 'expense', 8, NULL, FALSE, NULL),
('2024-06-25', 'Software subscriptions', 650.00, 'expense', 7, NULL, TRUE, 'monthly');

-- Insert sales stages
INSERT INTO sales_stages (stage_name, description, stage_order)
VALUES 
('Lead', 'Initial contact with potential customer', 1),
('Qualified', 'Lead has been qualified as a potential customer', 2),
('Proposal', 'Proposal or quote has been sent', 3),
('Negotiation', 'In active negotiation with customer', 4),
('Closed Won', 'Deal has been closed successfully', 5),
('Closed Lost', 'Deal has been lost', 6);

-- Insert sales funnel data
INSERT INTO sales_funnel_entries (customer_id, stage_id, entry_date, exit_date, value, converted, notes)
VALUES 
-- Leads
(1, 1, '2024-05-01', '2024-05-10', 8000.00, TRUE, 'Initial contact via website'),
(2, 1, '2024-05-05', '2024-05-15', 15000.00, TRUE, 'Referral from existing customer'),
(3, 1, '2024-05-10', NULL, 5000.00, FALSE, 'Cold call outreach'),
(4, 1, '2024-05-12', '2024-05-20', 25000.00, TRUE, 'Contacted us through LinkedIn'),
(5, 1, '2024-05-15', '2024-05-25', 12000.00, TRUE, 'Met at industry conference'),
(6, 1, '2024-05-18', '2024-05-28', 18000.00, TRUE, 'Responded to email campaign'),
(7, 1, '2024-05-20', NULL, 30000.00, FALSE, 'Website form submission'),
(8, 1, '2024-05-22', NULL, 7000.00, FALSE, 'Social media contact'),
(9, 1, '2024-05-25', '2024-06-05', 14000.00, TRUE, 'Partner referral'),
(10, 1, '2024-05-30', '2024-06-10', 35000.00, TRUE, 'Webinar attendee'),

-- Qualified
(1, 2, '2024-05-10', '2024-05-20', 8000.00, TRUE, 'Discussed project requirements'),
(2, 2, '2024-05-15', '2024-05-25', 15000.00, TRUE, 'Presented product demo'),
(4, 2, '2024-05-20', '2024-05-30', 25000.00, TRUE, 'Identified specific needs'),
(5, 2, '2024-05-25', '2024-06-05', 12000.00, TRUE, 'Scheduled follow-up demo'),
(6, 2, '2024-05-28', NULL, 18000.00, FALSE, 'Waiting for budget approval'),
(9, 2, '2024-06-05', NULL, 14000.00, FALSE, 'Technical assessment in progress'),
(10, 2, '2024-06-10', '2024-06-20', 35000.00, TRUE, 'Completed needs assessment'),

-- Proposal
(1, 3, '2024-05-20', '2024-05-30', 8000.00, TRUE, 'Sent detailed proposal'),
(2, 3, '2024-05-25', '2024-06-05', 15000.00, TRUE, 'Proposal with custom options'),
(4, 3, '2024-05-30', NULL, 25000.00, FALSE, 'Reviewing proposal internally'),
(5, 3, '2024-06-05', '2024-06-15', 12000.00, TRUE, 'Presented proposal to team'),
(10, 3, '2024-06-20', NULL, 35000.00, FALSE, 'Awaiting feedback on proposal'),

-- Negotiation
(1, 4, '2024-05-30', '2024-06-10', 8000.00, TRUE, 'Price negotiation'),
(2, 4, '2024-06-05', NULL, 15000.00, FALSE, 'Discussing contract terms'),
(5, 4, '2024-06-15', '2024-06-25', 12000.00, TRUE, 'Final contract review'),

-- Closed Won
(1, 5, '2024-06-10', NULL, 8000.00, FALSE, 'Deal signed, implementation starting'),
(5, 5, '2024-06-25', NULL, 12000.00, FALSE, 'Contract finalized, kickoff next week'),

-- Closed Lost
(NULL, 6, '2024-05-20', NULL, 6000.00, FALSE, 'Chose competitor solution'),
(NULL, 6, '2024-06-01', NULL, 10000.00, FALSE, 'Budget constraints'),
(NULL, 6, '2024-06-12', NULL, 22000.00, FALSE, 'Project postponed indefinitely');

-- Insert cashflow projections
INSERT INTO cashflow_projections (projection_date, projected_inflow, projected_outflow, actual_inflow, actual_outflow, notes)
VALUES 
('2024-01-31', 30000.00, 15000.00, 32580.00, 18423.00, 'January projection'),
('2024-02-28', 32000.00, 16000.00, 31200.00, 17800.00, 'February projection'),
('2024-03-31', 35000.00, 16500.00, 34200.00, 17650.00, 'March projection'),
('2024-04-30', 37000.00, 17000.00, 38520.00, 18240.00, 'April projection'),
('2024-05-31', 39000.00, 17500.00, 40100.00, 18300.00, 'May projection'),
('2024-06-30', 42000.00, 18000.00, NULL, NULL, 'June projection - actuals pending'),
('2024-07-31', 44000.00, 18500.00, NULL, NULL, 'July projection'),
('2024-08-31', 45000.00, 19000.00, NULL, NULL, 'August projection'),
('2024-09-30', 47000.00, 19500.00, NULL, NULL, 'September projection'),
('2024-10-31', 49000.00, 20000.00, NULL, NULL, 'October projection'),
('2024-11-30', 52000.00, 21000.00, NULL, NULL, 'November projection'),
('2024-12-31', 55000.00, 22000.00, NULL, NULL, 'December projection');

-- Insert KPI metrics
INSERT INTO kpi_metrics (metric_name, metric_value, target_value, metric_date, metric_type, description)
VALUES 
-- Profitability metrics
('Profit Margin', 43.45, 45.00, '2024-06-01', 'percentage', 'Net profit divided by revenue'),
('Return on Investment', 18.30, 20.00, '2024-06-01', 'percentage', 'Net profit divided by investment'),
('Cost-Income Ratio', 56.55, 55.00, '2024-06-01', 'percentage', 'Operating costs divided by operating income'),

-- Liquidity metrics
('Current Ratio', 2.80, 2.50, '2024-06-01', 'ratio', 'Current assets divided by current liabilities'),
('Quick Ratio', 1.90, 1.50, '2024-06-01', 'ratio', 'Liquid assets divided by current liabilities'),
('Cash Conversion Cycle', 36.50, 30.00, '2024-06-01', 'number', 'Days to convert resources into cash flows'),

-- Growth metrics
('Revenue Growth Rate', 15.80, 20.00, '2024-06-01', 'percentage', 'Year-over-year revenue growth'),
('Customer Acquisition Cost', 320.00, 300.00, '2024-06-01', 'currency', 'Cost to acquire a new customer'),
('Customer Lifetime Value', 1850.00, 2000.00, '2024-06-01', 'currency', 'Total value of a customer relationship'); 