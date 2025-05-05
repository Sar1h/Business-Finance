USE bufi_finance;

-- ====================================================
--  TEST QUERIES FOR BUFI FINANCE DATABASE
-- ====================================================

-- This file contains queries to test and demonstrate the functionality
-- of the views, joins, and triggers implemented in the database schema.
-- Run these after loading the sample data.

-- ====================================================
--  TESTING VIEWS
-- ====================================================

-- Test 1: Financial Health Dashboard View
-- Shows monthly financial summary with revenue, expenses, and profit
SELECT * FROM vw_financial_health
ORDER BY year DESC, month DESC
LIMIT 5;

-- Test 2: Cash Flow Analysis View
-- Shows projected vs actual cash flow with status indicators
SELECT * FROM vw_cashflow_analysis
ORDER BY period_date DESC
LIMIT 3;

-- Test 3: Revenue Analysis View
-- Analyzes customer revenue patterns
SELECT * FROM vw_revenue_analysis
ORDER BY total_revenue DESC
LIMIT 5;

-- Test 4: Expense Analysis View
-- Categorizes expenses with optimization opportunities
SELECT * FROM vw_expense_analysis
ORDER BY total_expense DESC
LIMIT 5;

-- Test 5: Sales Pipeline View
-- Summarizes sales opportunities by stage
SELECT * FROM vw_sales_pipeline
ORDER BY stage_order;

-- Test 6: Customer Concentration Risk Analysis
-- Identifies customer dependency risks
SELECT * FROM vw_customer_concentration_risk
ORDER BY percentage_of_revenue DESC;

-- Test 7: Inventory Status View
-- Shows inventory status with stock level indicators
SELECT * FROM vw_inventory_status
ORDER BY stock_status ASC, margin_percentage DESC;

-- ====================================================
--  TESTING JOINS
-- ====================================================

-- Test 8: Customer Revenue Analysis with Segments
-- Demonstrates JOIN between customers, segments, and transactions
SELECT 
    c.name AS customer_name,
    cs.segment_name,
    c.business_size,
    COUNT(t.id) AS transaction_count,
    SUM(t.amount) AS total_revenue,
    AVG(t.amount) AS average_transaction_value,
    MAX(t.transaction_date) AS last_transaction_date,
    c.lifetime_value
FROM 
    customers c
    INNER JOIN customer_segments cs ON c.segment_id = cs.id
    LEFT JOIN transactions t ON c.id = t.customer_id AND t.type = 'revenue'
GROUP BY 
    c.id, c.name, cs.segment_name, c.business_size, c.lifetime_value
ORDER BY 
    total_revenue DESC;

-- Test 9: Transaction Details with Category Information
-- Demonstrates JOIN between transactions and categories
SELECT 
    t.id,
    t.transaction_date,
    t.description,
    t.amount,
    t.type,
    cat.category_name,
    cat.is_recurring,
    cat.is_fixed,
    cat.is_tax_deductible,
    c.name AS customer_name
FROM 
    transactions t
    INNER JOIN categories cat ON t.category_id = cat.id
    LEFT JOIN customers c ON t.customer_id = c.id
ORDER BY 
    t.transaction_date DESC
LIMIT 20;

-- Test 10: Sales Pipeline with Customer Details
-- Demonstrates JOIN between sales_pipeline and customers
SELECT 
    sp.stage_name,
    sp.stage_order,
    c.name AS customer_name,
    c.business_size,
    cs.segment_name,
    sp.value,
    sp.confidence_score,
    sp.value * (sp.confidence_score/100) AS weighted_value,
    sp.entry_date,
    sp.expected_close_date,
    DATEDIFF(sp.expected_close_date, CURRENT_DATE()) AS days_to_expected_close
FROM 
    sales_pipeline sp
    INNER JOIN customers c ON sp.customer_id = c.id
    INNER JOIN customer_segments cs ON c.segment_id = cs.id
WHERE 
    sp.exit_date IS NULL
ORDER BY 
    sp.stage_order, sp.confidence_score DESC;

-- Test 11: Monthly Expense Breakdown by Category
-- Demonstrates GROUP BY with date functions and JOIN
SELECT 
    YEAR(t.transaction_date) AS year,
    MONTH(t.transaction_date) AS month,
    cat.category_name,
    SUM(t.amount) AS total_amount,
    COUNT(t.id) AS transaction_count,
    AVG(t.amount) AS average_amount
FROM 
    transactions t
    INNER JOIN categories cat ON t.category_id = cat.id
WHERE 
    t.type = 'expense'
GROUP BY 
    YEAR(t.transaction_date), 
    MONTH(t.transaction_date),
    cat.category_name
ORDER BY 
    year DESC, 
    month DESC, 
    total_amount DESC;

-- Test 12: Tax Calendar with Related Transaction Amounts
-- Demonstrates SUBQUERY with date range
SELECT 
    tc.tax_type,
    tc.period_start,
    tc.period_end,
    tc.due_date,
    tc.amount_due,
    tc.is_paid,
    (SELECT SUM(amount) 
     FROM transactions 
     WHERE type = 'expense' 
       AND tax_relevant = TRUE 
       AND transaction_date BETWEEN tc.period_start AND tc.period_end) AS tax_relevant_expenses,
    (SELECT SUM(amount) 
     FROM transactions 
     WHERE type = 'revenue' 
       AND tax_relevant = TRUE 
       AND transaction_date BETWEEN tc.period_start AND tc.period_end) AS taxable_revenue,
    DATEDIFF(tc.due_date, CURRENT_DATE()) AS days_until_due,
    CASE 
        WHEN tc.is_paid = TRUE THEN 'Paid'
        WHEN tc.due_date < CURRENT_DATE() THEN 'Overdue'
        WHEN DATEDIFF(tc.due_date, CURRENT_DATE()) <= 15 THEN 'Due Soon'
        ELSE 'Upcoming'
    END AS payment_status
FROM 
    tax_calendar tc
ORDER BY 
    tc.due_date;

-- ====================================================
--  TESTING TRIGGERS
-- ====================================================

-- Test 13: Customer Lifetime Value Trigger
-- Insert a new revenue transaction and see the customer's lifetime value update
SELECT id, name, lifetime_value, last_purchase_date FROM customers WHERE id = 1;

-- Add new transaction
INSERT INTO transactions (
    transaction_date, description, amount, type, category_id, 
    customer_id, recurring, tax_relevant, payment_method, invoice_id
) VALUES (
    CURRENT_DATE(), 'Test transaction for trigger', 2500.00, 'revenue', 
    3, 1, FALSE, TRUE, 'Credit Card', 'TEST-TRIG-001'
);

-- Verify lifetime value updated
SELECT id, name, lifetime_value, last_purchase_date FROM customers WHERE id = 1;

-- Check if a financial insight was generated (if amount > 2x avg)
SELECT * FROM financial_insights 
WHERE title LIKE '%Acme Corporation%' 
AND insight_date > DATE_SUB(NOW(), INTERVAL 1 MINUTE)
ORDER BY insight_date DESC LIMIT 1;

-- Test 14: Cashflow Projection Trigger
-- Insert a recurring transaction and check if cashflow projections were created
-- First, check current projections
SELECT * FROM cashflow 
WHERE period_date > CURRENT_DATE() 
ORDER BY period_date 
LIMIT 3;

-- Add recurring transaction
INSERT INTO transactions (
    transaction_date, description, amount, type, category_id, 
    customer_id, recurring, recurring_frequency, tax_relevant, payment_method, invoice_id
) VALUES (
    CURRENT_DATE(), 'Test recurring transaction', 1000.00, 'revenue', 
    3, 1, TRUE, 'monthly', TRUE, 'Bank Transfer', 'TEST-TRIG-002'
);

-- Check if cashflow projections were updated/created
SELECT * FROM cashflow 
WHERE period_date > CURRENT_DATE() 
  AND notes LIKE '%Test recurring transaction%'
ORDER BY period_date 
LIMIT 3;

-- Test 15: Tax Calendar Trigger
-- Insert a tax-relevant transaction and check if tax calendar was updated
-- First, check current tax calendar
SELECT * FROM tax_calendar 
WHERE period_start <= CURRENT_DATE() 
  AND period_end >= CURRENT_DATE();

-- Add tax-relevant transaction
INSERT INTO transactions (
    transaction_date, description, amount, type, category_id, 
    customer_id, recurring, tax_relevant, payment_method, invoice_id
) VALUES (
    CURRENT_DATE(), 'Test tax-relevant transaction', 5000.00, 'revenue', 
    1, 2, FALSE, TRUE, 'Bank Transfer', 'TEST-TRIG-003'
);

-- Check if tax calendar was updated
SELECT * FROM tax_calendar 
WHERE period_start <= CURRENT_DATE() 
  AND period_end >= CURRENT_DATE();

-- Test 16: Inventory Trigger
-- Simulate an inventory purchase and check if inventory was updated
-- First, check current inventory
SELECT * FROM inventory WHERE id = 1;

-- Add inventory purchase transaction with special formatted description (id:quantity)
INSERT INTO transactions (
    transaction_date, description, amount, type, category_id, 
    customer_id, recurring, tax_relevant, payment_method, invoice_id
) VALUES (
    CURRENT_DATE(), '1:5 - Business Laptop inventory restock', 4000.00, 'expense', 
    18, NULL, FALSE, TRUE, 'Bank Transfer', 'TEST-TRIG-004'
);

-- Check if inventory was updated
SELECT * FROM inventory WHERE id = 1;

-- Test 17: Expense Anomaly Detection Trigger
-- Insert an unusually high expense and check if an insight was generated
-- First, get average expense for a category
SELECT AVG(amount) AS avg_expense 
FROM transactions 
WHERE category_id = 15 AND type = 'expense';

-- Add an unusually high expense (3x the average)
INSERT INTO transactions (
    transaction_date, description, amount, type, category_id, 
    customer_id, recurring, tax_relevant, payment_method, invoice_id
) VALUES (
    CURRENT_DATE(), 'Unusually high office supplies expense', 
    (SELECT AVG(amount) * 3 FROM transactions WHERE category_id = 15 AND type = 'expense'), 
    'expense', 15, NULL, FALSE, TRUE, 'Credit Card', 'TEST-TRIG-005'
);

-- Check if an insight was generated
SELECT * FROM financial_insights 
WHERE category = 'expense' 
  AND insight_type = 'risk'
  AND insight_date > DATE_SUB(NOW(), INTERVAL 1 MINUTE)
ORDER BY insight_date DESC 
LIMIT 1;

-- ====================================================
--  COMPLEX ANALYSIS QUERIES
-- ====================================================

-- Test 18: Revenue Trend Analysis with Growth Rate
SELECT 
    current_month.year,
    current_month.month,
    current_month.total_revenue,
    prev_month.total_revenue AS prev_month_revenue,
    IFNULL(ROUND((current_month.total_revenue - prev_month.total_revenue) / 
           prev_month.total_revenue * 100, 2), 0) AS month_over_month_growth,
    prev_year.total_revenue AS prev_year_revenue,
    IFNULL(ROUND((current_month.total_revenue - prev_year.total_revenue) / 
           prev_year.total_revenue * 100, 2), 0) AS year_over_year_growth
FROM 
    (SELECT 
        YEAR(transaction_date) AS year,
        MONTH(transaction_date) AS month,
        SUM(amount) AS total_revenue
     FROM transactions
     WHERE type = 'revenue'
     GROUP BY year, month) AS current_month
LEFT JOIN 
    (SELECT 
        YEAR(transaction_date) AS year,
        MONTH(transaction_date) AS month,
        SUM(amount) AS total_revenue
     FROM transactions
     WHERE type = 'revenue'
     GROUP BY year, month) AS prev_month
ON 
    (current_month.year = prev_month.year AND current_month.month = prev_month.month + 1)
    OR (current_month.year = prev_month.year + 1 AND current_month.month = 1 AND prev_month.month = 12)
LEFT JOIN 
    (SELECT 
        YEAR(transaction_date) AS year,
        MONTH(transaction_date) AS month,
        SUM(amount) AS total_revenue
     FROM transactions
     WHERE type = 'revenue'
     GROUP BY year, month) AS prev_year
ON 
    current_month.year = prev_year.year + 1 AND current_month.month = prev_year.month
ORDER BY 
    current_month.year DESC, current_month.month DESC;

-- Test 19: Customer Cohort Analysis
SELECT 
    DATE_FORMAT(c.acquisition_date, '%Y-%m') AS cohort,
    COUNT(DISTINCT c.id) AS customers_acquired,
    SUM(CASE WHEN t.transaction_date BETWEEN c.acquisition_date AND DATE_ADD(c.acquisition_date, INTERVAL 30 DAY) 
             THEN t.amount ELSE 0 END) AS revenue_first_30_days,
    SUM(CASE WHEN t.transaction_date BETWEEN DATE_ADD(c.acquisition_date, INTERVAL 31 DAY) AND DATE_ADD(c.acquisition_date, INTERVAL 90 DAY) 
             THEN t.amount ELSE 0 END) AS revenue_31_to_90_days,
    SUM(CASE WHEN t.transaction_date > DATE_ADD(c.acquisition_date, INTERVAL 90 DAY) 
             THEN t.amount ELSE 0 END) AS revenue_after_90_days,
    ROUND(AVG(c.lifetime_value), 2) AS avg_lifetime_value,
    ROUND(SUM(c.lifetime_value) / COUNT(DISTINCT c.id), 2) AS revenue_per_customer
FROM 
    customers c
LEFT JOIN 
    transactions t ON c.id = t.customer_id AND t.type = 'revenue'
WHERE 
    c.acquisition_date IS NOT NULL
GROUP BY 
    cohort
ORDER BY 
    cohort DESC;

-- Test 20: Profitability Analysis by Customer Segment
SELECT 
    cs.segment_name,
    COUNT(DISTINCT c.id) AS customer_count,
    SUM(t_rev.revenue) AS total_revenue,
    SUM(t_exp.expenses) AS allocated_expenses,
    SUM(t_rev.revenue) - SUM(t_exp.expenses) AS gross_profit,
    ROUND((SUM(t_rev.revenue) - SUM(t_exp.expenses)) / SUM(t_rev.revenue) * 100, 2) AS profit_margin,
    ROUND(SUM(t_rev.revenue) / COUNT(DISTINCT c.id), 2) AS revenue_per_customer,
    ROUND(SUM(t_exp.expenses) / COUNT(DISTINCT c.id), 2) AS cost_per_customer
FROM 
    customer_segments cs
INNER JOIN 
    customers c ON cs.id = c.segment_id
LEFT JOIN 
    (SELECT 
        customer_id, 
        SUM(amount) AS revenue
     FROM 
        transactions
     WHERE 
        type = 'revenue'
     GROUP BY 
        customer_id) AS t_rev ON c.id = t_rev.customer_id
LEFT JOIN 
    (SELECT 
        customer_id,
        SUM(amount) AS expenses
     FROM 
        transactions
     WHERE 
        type = 'expense' AND customer_id IS NOT NULL
     GROUP BY 
        customer_id) AS t_exp ON c.id = t_exp.customer_id
GROUP BY 
    cs.segment_name
ORDER BY 
    gross_profit DESC;

-- Test 21: Cash Flow Forecast
SELECT 
    future_periods.period_date,
    COALESCE(cf.projected_inflow, 0) AS base_projected_inflow,
    COALESCE(cf.projected_outflow, 0) AS base_projected_outflow,
    COALESCE(cf.projected_inflow, 0) + 
        COALESCE(recurring_revenue.amount, 0) AS adjusted_projected_inflow,
    COALESCE(cf.projected_outflow, 0) + 
        COALESCE(recurring_expenses.amount, 0) AS adjusted_projected_outflow,
    (COALESCE(cf.projected_inflow, 0) + COALESCE(recurring_revenue.amount, 0)) - 
        (COALESCE(cf.projected_outflow, 0) + COALESCE(recurring_expenses.amount, 0)) AS projected_net_cashflow
FROM 
    (SELECT DATE_FORMAT(period_date, '%Y-%m-01') AS period_date 
     FROM 
        (SELECT CURDATE() AS period_date
         UNION SELECT DATE_ADD(CURDATE(), INTERVAL 1 MONTH)
         UNION SELECT DATE_ADD(CURDATE(), INTERVAL 2 MONTH)
         UNION SELECT DATE_ADD(CURDATE(), INTERVAL 3 MONTH)
         UNION SELECT DATE_ADD(CURDATE(), INTERVAL 4 MONTH)
         UNION SELECT DATE_ADD(CURDATE(), INTERVAL 5 MONTH)
         UNION SELECT DATE_ADD(CURDATE(), INTERVAL 6 MONTH)) AS dates) AS future_periods
LEFT JOIN 
    cashflow cf ON DATE_FORMAT(cf.period_date, '%Y-%m-01') = future_periods.period_date
LEFT JOIN 
    (SELECT 
         DATE_FORMAT(DATE_ADD(transaction_date, INTERVAL m.n MONTH), '%Y-%m-01') AS period_date,
         SUM(amount) AS amount
     FROM 
         transactions,
         (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) AS m
     WHERE 
         recurring = TRUE 
         AND type = 'revenue'
         AND DATE_ADD(transaction_date, INTERVAL m.n MONTH) > CURDATE()
         AND DATE_ADD(transaction_date, INTERVAL m.n MONTH) < DATE_ADD(CURDATE(), INTERVAL 7 MONTH)
     GROUP BY 
         period_date) AS recurring_revenue 
ON future_periods.period_date = recurring_revenue.period_date
LEFT JOIN 
    (SELECT 
         DATE_FORMAT(DATE_ADD(transaction_date, INTERVAL m.n MONTH), '%Y-%m-01') AS period_date,
         SUM(amount) AS amount
     FROM 
         transactions,
         (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) AS m
     WHERE 
         recurring = TRUE 
         AND type = 'expense'
         AND DATE_ADD(transaction_date, INTERVAL m.n MONTH) > CURDATE()
         AND DATE_ADD(transaction_date, INTERVAL m.n MONTH) < DATE_ADD(CURDATE(), INTERVAL 7 MONTH)
     GROUP BY 
         period_date) AS recurring_expenses
ON future_periods.period_date = recurring_expenses.period_date
ORDER BY 
    future_periods.period_date;

-- ====================================================
--  TESTING DATA INTEGRITY
-- ====================================================

-- Test 22: Verify trigger data consistency for customer lifetime value
SELECT 
    c.id, 
    c.name, 
    c.lifetime_value AS stored_lifetime_value,
    SUM(t.amount) AS calculated_lifetime_value,
    ABS(c.lifetime_value - SUM(t.amount)) AS difference
FROM 
    customers c
JOIN 
    transactions t ON c.id = t.customer_id
WHERE 
    t.type = 'revenue'
GROUP BY 
    c.id, c.name, c.lifetime_value
HAVING 
    ABS(c.lifetime_value - SUM(t.amount)) > 0.01
ORDER BY 
    difference DESC;

-- Test 23: Check for orphaned records
SELECT 'Categories without transactions' AS check_type, 
       COUNT(*) AS orphaned_records
FROM categories c
LEFT JOIN transactions t ON c.id = t.category_id
WHERE t.id IS NULL

UNION ALL

SELECT 'Customers without transactions' AS check_type, 
       COUNT(*) AS orphaned_records
FROM customers c
LEFT JOIN transactions t ON c.id = t.customer_id
WHERE t.id IS NULL

UNION ALL

SELECT 'Customer segments without customers' AS check_type, 
       COUNT(*) AS orphaned_records
FROM customer_segments cs
LEFT JOIN customers c ON cs.id = c.segment_id
WHERE c.id IS NULL;

-- Test 24: Validate Transaction Tax Calendar Consistency
SELECT 
    tax_type,
    period_start,
    period_end,
    amount_due AS tax_calendar_amount,
    (SELECT SUM(amount) * 0.15 
     FROM transactions 
     WHERE tax_relevant = TRUE 
       AND transaction_date BETWEEN tc.period_start AND tc.period_end
       AND type = CASE 
                    WHEN tc.tax_type = 'Income Tax' THEN 'revenue'
                    WHEN tc.tax_type = 'VAT/Sales Tax' THEN 'revenue'
                    ELSE type
                  END) AS calculated_amount,
    ABS(amount_due - (SELECT SUM(amount) * 0.15 
                     FROM transactions 
                     WHERE tax_relevant = TRUE 
                       AND transaction_date BETWEEN tc.period_start AND tc.period_end
                       AND type = CASE 
                                    WHEN tc.tax_type = 'Income Tax' THEN 'revenue'
                                    WHEN tc.tax_type = 'VAT/Sales Tax' THEN 'revenue'
                                    ELSE type
                                  END)) AS difference
FROM 
    tax_calendar tc
WHERE
    tax_type IN ('Income Tax', 'VAT/Sales Tax')
    AND period_end < CURRENT_DATE()
HAVING
    calculated_amount IS NOT NULL
ORDER BY
    difference DESC; 