USE bufi_finance;

-- ====================================================
--  SAMPLE DATA FOR BUFI FINANCE DATABASE
-- ====================================================

-- ====================================================
--  CATEGORIES
-- ====================================================

INSERT INTO categories (category_name, description, type, is_recurring, is_fixed, is_tax_deductible) VALUES
-- Revenue Categories
('Product Sales', 'Revenue from product sales', 'revenue', FALSE, FALSE, FALSE),
('Services', 'Revenue from services provided', 'revenue', TRUE, FALSE, FALSE),
('Subscriptions', 'Recurring subscription revenue', 'revenue', TRUE, TRUE, FALSE),
('Rental Income', 'Income from property or equipment rental', 'revenue', TRUE, TRUE, FALSE),
('Affiliate Revenue', 'Commission from referrals', 'revenue', FALSE, FALSE, FALSE),
('Consulting', 'Revenue from consulting services', 'revenue', FALSE, FALSE, FALSE),
('Digital Products', 'Revenue from digital downloads', 'revenue', FALSE, FALSE, FALSE),
('Licensing', 'Revenue from licensing intellectual property', 'revenue', TRUE, TRUE, FALSE),
('Workshops', 'Revenue from hosting workshops', 'revenue', FALSE, FALSE, FALSE),
('Custom Development', 'Revenue from custom software development', 'revenue', FALSE, FALSE, FALSE),

-- Expense Categories
('Rent', 'Office or warehouse rent', 'expense', TRUE, TRUE, TRUE),
('Utilities', 'Electricity, water, internet', 'expense', TRUE, TRUE, TRUE),
('Salaries', 'Employee salaries and wages', 'expense', TRUE, TRUE, TRUE),
('Marketing', 'Advertising and promotion expenses', 'expense', FALSE, FALSE, TRUE),
('Office Supplies', 'General office supplies', 'expense', FALSE, FALSE, TRUE),
('Software Subscriptions', 'Software and digital tools', 'expense', TRUE, TRUE, TRUE),
('Professional Services', 'Legal, accounting, consulting', 'expense', FALSE, FALSE, TRUE),
('Inventory Purchase', 'Purchase of goods for resale', 'expense', FALSE, FALSE, TRUE),
('Travel', 'Business travel expenses', 'expense', FALSE, FALSE, TRUE),
('Equipment', 'Purchase of equipment', 'expense', FALSE, FALSE, TRUE),
('Insurance', 'Business insurance premiums', 'expense', TRUE, TRUE, TRUE),
('Taxes', 'Business taxes', 'expense', TRUE, TRUE, FALSE),
('Training', 'Employee training and development', 'expense', FALSE, FALSE, TRUE),
('Maintenance', 'Equipment and property maintenance', 'expense', FALSE, FALSE, TRUE),
('Miscellaneous', 'Other expenses', 'expense', FALSE, FALSE, TRUE);

-- ====================================================
--  USERS
-- ====================================================

INSERT INTO users (username, password, email, full_name, role) VALUES
('admin', '$2y$10$Ab12CdEfGhIjKlMnOpQrSt.uvwxYZ98765432HgFdSa', 'admin@bufi.com', 'Admin User', 'admin'),
('john.doe', '$2y$10$12AbCdEfGhIjKlMnOpQrSt.uvwxYZ98765432HgFdSa', 'john.doe@bufi.com', 'John Doe', 'user'),
('jane.smith', '$2y$10$12AbCdEfGhIjKlMnOpQrSt.uvwxYZ98765432HgFdSa', 'jane.smith@bufi.com', 'Jane Smith', 'financial_advisor'),
('investor1', '$2y$10$12AbCdEfGhIjKlMnOpQrSt.uvwxYZ98765432HgFdSa', 'investor1@example.com', 'Investment Partner', 'investor');

-- ====================================================
--  CUSTOMER SEGMENTS
-- ====================================================

INSERT INTO customer_segments (segment_name, description, profitability_score, growth_potential) VALUES
('Enterprise', 'Large enterprise clients with 1000+ employees', 85.50, 'Medium'),
('SMB', 'Small and medium-sized businesses with 10-999 employees', 75.75, 'High'),
('Startup', 'Early-stage companies with high growth potential', 60.25, 'High'),
('Non-Profit', 'Non-profit organizations and associations', 45.00, 'Low'),
('Government', 'Government agencies and departments', 70.50, 'Low');

-- ====================================================
--  CUSTOMERS
-- ====================================================

INSERT INTO customers (name, email, phone, address, segment_id, business_size, acquisition_date, risk_score, payment_reliability) VALUES
('Acme Corporation', 'contact@acme.com', '555-123-4567', '123 Main St, Business City, 12345', 1, 'Enterprise', '2022-01-15', 30.50, 95.00),
('TechStart Inc', 'info@techstart.io', '555-987-6543', '456 Innovation Dr, Startup Town, 54321', 3, 'Small', '2022-03-22', 65.75, 85.50),
('Community Services', 'admin@communityservices.org', '555-456-7890', '789 Helper Ave, Charity City, 67890', 4, 'Medium', '2022-02-10', 45.25, 90.00),
('City of Springfield', 'info@springfield.gov', '555-789-0123', '321 Government Blvd, Springfield, 13579', 5, 'Large', '2022-04-05', 25.00, 100.00),
('Global Enterprises', 'contact@global.co', '555-321-6547', '987 Corporate Park, Big City, 24680', 1, 'Enterprise', '2022-01-30', 35.50, 97.50),
('Local Shop', 'owner@localshop.com', '555-852-9631', '741 Market St, Small Town, 97531', 2, 'Small', '2022-05-12', 60.00, 88.00),
('Tech Innovators', 'hello@techinnovators.com', '555-159-7532', '852 Future Ave, Tech City, 15935', 3, 'Medium', '2022-03-15', 70.25, 82.50),
('Education Foundation', 'contact@edufo.org', '555-753-1595', '426 Learning Lane, Knowledge City, 35795', 4, 'Medium', '2022-06-01', 40.75, 92.00),
('Manufacturing Pro', 'info@manufacturingpro.com', '555-357-9512', '159 Factory Rd, Industrial Park, 75312', 2, 'Large', '2022-02-25', 45.00, 93.50),
('Health Services', 'admin@healthservices.med', '555-951-7532', '357 Wellness Way, Health City, 15753', 2, 'Medium', '2022-04-18', 50.50, 89.00);

-- ====================================================
--  INVENTORY
-- ====================================================

INSERT INTO inventory (item_name, sku, cost_price, selling_price, current_stock, reorder_level, supplier, last_restock_date) VALUES
('Business Laptop', 'TECH-001', 800.00, 1200.00, 25, 10, 'Tech Wholesale', '2023-01-15'),
('Office Desk', 'FURN-001', 200.00, 350.00, 15, 5, 'Furniture Supply Co', '2023-02-20'),
('Ergonomic Chair', 'FURN-002', 150.00, 275.00, 20, 8, 'Furniture Supply Co', '2023-02-20'),
('Wireless Keyboard', 'TECH-002', 30.00, 59.99, 50, 15, 'Tech Wholesale', '2023-01-15'),
('Wireless Mouse', 'TECH-003', 15.00, 29.99, 60, 20, 'Tech Wholesale', '2023-01-15'),
('Monitor 24"', 'TECH-004', 120.00, 199.99, 30, 10, 'Tech Wholesale', '2023-03-05'),
('Printer', 'TECH-005', 250.00, 399.99, 10, 5, 'Office Equipment Inc', '2023-03-10'),
('Filing Cabinet', 'FURN-003', 100.00, 179.99, 12, 6, 'Furniture Supply Co', '2023-02-20'),
('Premium Notebook', 'STAT-001', 5.00, 12.99, 100, 30, 'Stationery Suppliers', '2023-04-01'),
('Whiteboard', 'OFF-001', 45.00, 89.99, 8, 3, 'Office Equipment Inc', '2023-03-10');

-- ====================================================
--  TRANSACTIONS
-- ====================================================

-- Need to insert both revenue and expense transactions with proper references
-- Revenue transactions
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-10', 'Monthly software subscription', 1500.00, 'revenue', 3, 1, TRUE, 'monthly', TRUE, 'Credit Card', 'INV-2023-001');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-15', 'Consulting services', 3500.00, 'revenue', 6, 2, FALSE, NULL, TRUE, 'Bank Transfer', 'INV-2023-002');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-20', 'Product sale - Business laptops x5', 6000.00, 'revenue', 1, 3, FALSE, NULL, TRUE, 'Check', 'INV-2023-003');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-25', 'Custom software development', 8500.00, 'revenue', 10, 4, FALSE, NULL, TRUE, 'Bank Transfer', 'INV-2023-004');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-01', 'Rental of equipment', 750.00, 'revenue', 4, 5, TRUE, 'monthly', TRUE, 'ACH', 'INV-2023-005');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-10', 'Monthly software subscription', 1500.00, 'revenue', 3, 1, TRUE, 'monthly', TRUE, 'Credit Card', 'INV-2023-006');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-15', 'Workshop hosting fees', 1250.00, 'revenue', 9, 6, FALSE, NULL, TRUE, 'Credit Card', 'INV-2023-007');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-20', 'Consulting services', 2750.00, 'revenue', 6, 7, FALSE, NULL, TRUE, 'Bank Transfer', 'INV-2023-008');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-25', 'Digital product sales', 950.00, 'revenue', 7, 8, FALSE, NULL, TRUE, 'PayPal', 'INV-2023-009');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-01', 'Rental of equipment', 750.00, 'revenue', 4, 5, TRUE, 'monthly', TRUE, 'ACH', 'INV-2023-010');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-05', 'Product sale - Office furniture', 4250.00, 'revenue', 1, 9, FALSE, NULL, TRUE, 'Bank Transfer', 'INV-2023-011');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-10', 'Monthly software subscription', 1500.00, 'revenue', 3, 1, TRUE, 'monthly', TRUE, 'Credit Card', 'INV-2023-012');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-15', 'Licensing fees', 2000.00, 'revenue', 8, 10, TRUE, 'quarterly', TRUE, 'Bank Transfer', 'INV-2023-013');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-20', 'Product sale - Tech accessories', 1850.00, 'revenue', 1, 2, FALSE, NULL, TRUE, 'Credit Card', 'INV-2023-014');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-25', 'Consulting services', 4500.00, 'revenue', 6, 3, FALSE, NULL, TRUE, 'Bank Transfer', 'INV-2023-015');

-- Expense transactions
INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-05', 'Office rent January', 2500.00, 'expense', 11, NULL, TRUE, 'monthly', TRUE, 'ACH', 'EXP-2023-001');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-07', 'Internet service', 150.00, 'expense', 12, NULL, TRUE, 'monthly', TRUE, 'Credit Card', 'EXP-2023-002');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-15', 'Employee payroll', 12500.00, 'expense', 13, NULL, TRUE, 'monthly', TRUE, 'Bank Transfer', 'EXP-2023-003');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-18', 'Office supplies', 350.00, 'expense', 15, NULL, FALSE, NULL, TRUE, 'Credit Card', 'EXP-2023-004');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-22', 'Digital marketing campaign', 1500.00, 'expense', 14, NULL, FALSE, NULL, TRUE, 'Credit Card', 'EXP-2023-005');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-25', 'Software licenses', 750.00, 'expense', 16, NULL, TRUE, 'annually', TRUE, 'Credit Card', 'EXP-2023-006');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-01-30', 'Legal services', 1200.00, 'expense', 17, NULL, FALSE, NULL, TRUE, 'Bank Transfer', 'EXP-2023-007');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-01', '1:10 - Business Laptops inventory purchase', 8000.00, 'expense', 18, NULL, FALSE, NULL, TRUE, 'Bank Transfer', 'EXP-2023-008');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-05', 'Office rent February', 2500.00, 'expense', 11, NULL, TRUE, 'monthly', TRUE, 'ACH', 'EXP-2023-009');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-07', 'Internet service', 150.00, 'expense', 12, NULL, TRUE, 'monthly', TRUE, 'Credit Card', 'EXP-2023-010');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-10', 'Travel expenses - client meeting', 850.00, 'expense', 19, 1, FALSE, NULL, TRUE, 'Credit Card', 'EXP-2023-011');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-15', 'Employee payroll', 12500.00, 'expense', 13, NULL, TRUE, 'monthly', TRUE, 'Bank Transfer', 'EXP-2023-012');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-20', 'New office equipment', 3500.00, 'expense', 20, NULL, FALSE, NULL, TRUE, 'Bank Transfer', 'EXP-2023-013');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-25', 'Business insurance premium', 1800.00, 'expense', 21, NULL, TRUE, 'quarterly', TRUE, 'Bank Transfer', 'EXP-2023-014');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-02-28', 'Professional development workshop', 1200.00, 'expense', 23, NULL, FALSE, NULL, TRUE, 'Credit Card', 'EXP-2023-015');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-05', 'Office rent March', 2500.00, 'expense', 11, NULL, TRUE, 'monthly', TRUE, 'ACH', 'EXP-2023-016');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-07', 'Internet service', 150.00, 'expense', 12, NULL, TRUE, 'monthly', TRUE, 'Credit Card', 'EXP-2023-017');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-12', 'Equipment maintenance', 450.00, 'expense', 24, NULL, FALSE, NULL, TRUE, 'Credit Card', 'EXP-2023-018');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-15', 'Employee payroll', 12500.00, 'expense', 13, NULL, TRUE, 'monthly', TRUE, 'Bank Transfer', 'EXP-2023-019');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-20', 'Quarterly tax payment', 5500.00, 'expense', 22, NULL, TRUE, 'quarterly', FALSE, 'Bank Transfer', 'EXP-2023-020');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-25', 'Office supplies', 275.00, 'expense', 15, NULL, FALSE, NULL, TRUE, 'Credit Card', 'EXP-2023-021');

INSERT INTO transactions (transaction_date, description, amount, type, category_id, customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id) VALUES
('2023-03-28', 'Digital marketing campaign', 1800.00, 'expense', 14, NULL, FALSE, NULL, TRUE, 'Credit Card', 'EXP-2023-022');

-- ====================================================
--  SALES PIPELINE
-- ====================================================

INSERT INTO sales_pipeline (customer_id, stage_name, stage_order, entry_date, exit_date, value, confidence_score, expected_close_date, notes) VALUES
(2, 'Lead', 1, '2023-02-15', '2023-02-28', 5000.00, 20.00, '2023-04-30', 'Initial contact at industry conference'),
(2, 'Qualified', 2, '2023-02-28', '2023-03-15', 5000.00, 40.00, '2023-04-30', 'Discussed needs and budget'),
(2, 'Proposal', 3, '2023-03-15', NULL, 5000.00, 60.00, '2023-04-30', 'Sent proposal for services'),
(3, 'Lead', 1, '2023-01-10', '2023-01-20', 12000.00, 20.00, '2023-05-15', 'Inbound website inquiry'),
(3, 'Qualified', 2, '2023-01-20', '2023-02-05', 12000.00, 40.00, '2023-05-15', 'Qualified need for enterprise solution'),
(3, 'Proposal', 3, '2023-02-05', '2023-03-01', 12000.00, 70.00, '2023-05-15', 'Proposal sent for review'),
(3, 'Negotiation', 4, '2023-03-01', NULL, 12000.00, 85.00, '2023-05-15', 'Discussing terms and pricing'),
(5, 'Lead', 1, '2023-03-10', '2023-03-20', 8500.00, 25.00, '2023-06-30', 'Referral from existing client'),
(5, 'Qualified', 2, '2023-03-20', NULL, 8500.00, 45.00, '2023-06-30', 'Initial meeting to discuss requirements'),
(7, 'Lead', 1, '2023-02-20', '2023-03-05', 15000.00, 30.00, '2023-07-15', 'Contact via LinkedIn'),
(7, 'Qualified', 2, '2023-03-05', '2023-03-25', 15000.00, 50.00, '2023-07-15', 'Demo provided, strong interest'),
(7, 'Proposal', 3, '2023-03-25', NULL, 15000.00, 65.00, '2023-07-15', 'Custom proposal for services'),
(9, 'Lead', 1, '2023-01-05', '2023-01-15', 6500.00, 20.00, '2023-04-15', 'Responded to marketing campaign'),
(9, 'Qualified', 2, '2023-01-15', '2023-02-10', 6500.00, 40.00, '2023-04-15', 'Confirmed needs match our offering'),
(9, 'Proposal', 3, '2023-02-10', '2023-03-01', 6500.00, 60.00, '2023-04-15', 'Proposal sent with options'),
(9, 'Negotiation', 4, '2023-03-01', '2023-03-20', 6500.00, 80.00, '2023-04-15', 'Discussing contract details'),
(9, 'Closed Won', 5, '2023-03-20', NULL, 6500.00, 100.00, '2023-04-15', 'Contract signed, implementation scheduled');

-- ====================================================
--  CASHFLOW
-- ====================================================

INSERT INTO cashflow (period_date, projected_inflow, projected_outflow, actual_inflow, actual_outflow, notes) VALUES
('2023-01-31', 15000.00, 20000.00, 15250.00, 20750.00, 'January actuals'),
('2023-02-28', 16000.00, 19500.00, 16500.00, 19200.00, 'February actuals'),
('2023-03-31', 17500.00, 19000.00, 18100.00, 19450.00, 'March actuals'),
('2023-04-30', 18000.00, 19000.00, NULL, NULL, 'April projections'),
('2023-05-31', 19000.00, 18500.00, NULL, NULL, 'May projections'),
('2023-06-30', 20000.00, 18000.00, NULL, NULL, 'June projections');

-- ====================================================
--  TAX CALENDAR
-- ====================================================

INSERT INTO tax_calendar (tax_type, due_date, amount_due, is_paid, period_start, period_end) VALUES
('Income Tax', '2023-04-15', 5800.00, FALSE, '2023-01-01', '2023-03-31'),
('VAT/Sales Tax', '2023-04-20', 3200.00, FALSE, '2023-01-01', '2023-03-31'),
('Payroll Tax', '2023-01-15', 3750.00, TRUE, '2022-10-01', '2022-12-31'),
('Income Tax', '2023-07-15', 0.00, FALSE, '2023-04-01', '2023-06-30'),
('VAT/Sales Tax', '2023-07-20', 0.00, FALSE, '2023-04-01', '2023-06-30'),
('Property Tax', '2023-09-30', 4500.00, FALSE, '2023-01-01', '2023-12-31');

-- ====================================================
--  FINANCIAL INSIGHTS
-- ====================================================

INSERT INTO financial_insights (insight_date, insight_type, category, title, description, impact_level, is_implemented, implementation_date) VALUES
('2023-02-15 09:30:00', 'opportunity', 'revenue', 'Upsell opportunity with Acme Corporation', 'Based on their usage patterns, Acme Corporation could benefit from our premium tier. Potential for $500/month increased revenue.', 'medium', FALSE, NULL),
('2023-02-20 14:45:00', 'risk', 'expense', 'Unusual expense in category: Marketing', 'Recent marketing expenses are 45% above monthly average. Review campaign effectiveness.', 'medium', TRUE, '2023-03-01'),
('2023-03-05 11:15:00', 'trend', 'cashflow', 'Improving cash flow trend', 'Cash flow has improved consistently over the last 3 months, with a 12% increase in operating margin.', 'low', FALSE, NULL),
('2023-03-10 16:20:00', 'recommendation', 'operations', 'Consolidate software subscriptions', 'Multiple overlapping software subscriptions identified. Consolidation could save $350 monthly.', 'high', FALSE, NULL),
('2023-03-15 10:30:00', 'risk', 'revenue', 'Customer concentration risk', 'Acme Corporation represents 28% of monthly recurring revenue, creating dependency risk.', 'high', FALSE, NULL),
('2023-03-18 13:45:00', 'opportunity', 'tax', 'Additional tax deduction opportunity', 'Recent equipment purchases qualify for accelerated depreciation, potentially reducing tax liability by $1,200.', 'medium', FALSE, NULL); 