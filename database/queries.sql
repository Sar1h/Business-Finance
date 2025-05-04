-- Useful SQL Queries for Bufi Financial Dashboard

-- ======================================================
-- DASHBOARD OVERVIEW
-- ======================================================

-- Monthly Revenue (Current Month)
SELECT SUM(amount) as monthly_revenue
FROM transactions
WHERE type = 'revenue'
AND MONTH(transaction_date) = MONTH(CURRENT_DATE())
AND YEAR(transaction_date) = YEAR(CURRENT_DATE());

-- Monthly Expenses (Current Month)
SELECT SUM(amount) as monthly_expenses
FROM transactions
WHERE type = 'expense'
AND MONTH(transaction_date) = MONTH(CURRENT_DATE())
AND YEAR(transaction_date) = YEAR(CURRENT_DATE());

-- Monthly Net Profit (Current Month)
SELECT 
  (SELECT SUM(amount) FROM transactions WHERE type = 'revenue' AND MONTH(transaction_date) = MONTH(CURRENT_DATE()) AND YEAR(transaction_date) = YEAR(CURRENT_DATE())) - 
  (SELECT SUM(amount) FROM transactions WHERE type = 'expense' AND MONTH(transaction_date) = MONTH(CURRENT_DATE()) AND YEAR(transaction_date) = YEAR(CURRENT_DATE())) 
  as net_profit;

-- Cash Balance (Current)
SELECT 
  (SELECT SUM(amount) FROM transactions WHERE type = 'revenue') - 
  (SELECT SUM(amount) FROM transactions WHERE type = 'expense') 
  as cash_balance;

-- Revenue percentage change from last month
SELECT 
  ((SELECT SUM(amount) FROM transactions WHERE type = 'revenue' AND MONTH(transaction_date) = MONTH(CURRENT_DATE()) AND YEAR(transaction_date) = YEAR(CURRENT_DATE())) - 
   (SELECT SUM(amount) FROM transactions WHERE type = 'revenue' AND MONTH(transaction_date) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) AND YEAR(transaction_date) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)))) / 
   (SELECT SUM(amount) FROM transactions WHERE type = 'revenue' AND MONTH(transaction_date) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) AND YEAR(transaction_date) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))) * 100 
   as revenue_percent_change;

-- Expenses percentage change from last month
SELECT 
  ((SELECT SUM(amount) FROM transactions WHERE type = 'expense' AND MONTH(transaction_date) = MONTH(CURRENT_DATE()) AND YEAR(transaction_date) = YEAR(CURRENT_DATE())) - 
   (SELECT SUM(amount) FROM transactions WHERE type = 'expense' AND MONTH(transaction_date) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) AND YEAR(transaction_date) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)))) / 
   (SELECT SUM(amount) FROM transactions WHERE type = 'expense' AND MONTH(transaction_date) = MONTH(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) AND YEAR(transaction_date) = YEAR(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))) * 100 
   as expense_percent_change;

-- ======================================================
-- REVENUE & EXPENSES
-- ======================================================

-- Monthly Revenue and Expenses for the Last 6 Months
SELECT 
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) AS revenue,
    SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS expense
FROM transactions
WHERE transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month;

-- Revenue Breakdown by Category (Current Month)
SELECT 
    rc.category_name, 
    SUM(t.amount) AS amount,
    (SUM(t.amount) / (SELECT SUM(amount) FROM transactions WHERE type = 'revenue' AND MONTH(transaction_date) = MONTH(CURRENT_DATE()) AND YEAR(transaction_date) = YEAR(CURRENT_DATE()))) * 100 AS percentage
FROM transactions t
JOIN revenue_categories rc ON t.category_id = rc.id
WHERE t.type = 'revenue'
AND MONTH(t.transaction_date) = MONTH(CURRENT_DATE())
AND YEAR(t.transaction_date) = YEAR(CURRENT_DATE())
GROUP BY rc.category_name
ORDER BY amount DESC;

-- Expense Breakdown by Category (Current Month)
SELECT 
    ec.category_name, 
    SUM(t.amount) AS amount,
    (SUM(t.amount) / (SELECT SUM(amount) FROM transactions WHERE type = 'expense' AND MONTH(transaction_date) = MONTH(CURRENT_DATE()) AND YEAR(transaction_date) = YEAR(CURRENT_DATE()))) * 100 AS percentage
FROM transactions t
JOIN expense_categories ec ON t.category_id = ec.id
WHERE t.type = 'expense'
AND MONTH(t.transaction_date) = MONTH(CURRENT_DATE())
AND YEAR(t.transaction_date) = YEAR(CURRENT_DATE())
GROUP BY ec.category_name
ORDER BY amount DESC;

-- Top 5 Customers by Revenue (Year to Date)
SELECT 
    c.name, 
    SUM(t.amount) AS total_revenue
FROM transactions t
JOIN customers c ON t.customer_id = c.id
WHERE t.type = 'revenue'
AND YEAR(t.transaction_date) = YEAR(CURRENT_DATE())
GROUP BY c.name
ORDER BY total_revenue DESC
LIMIT 5;

-- Fixed vs Variable Expenses (Current Month)
SELECT 
    CASE WHEN ec.is_fixed THEN 'Fixed' ELSE 'Variable' END AS expense_type,
    SUM(t.amount) AS total_amount
FROM transactions t
JOIN expense_categories ec ON t.category_id = ec.id
WHERE t.type = 'expense'
AND MONTH(t.transaction_date) = MONTH(CURRENT_DATE())
AND YEAR(t.transaction_date) = YEAR(CURRENT_DATE())
GROUP BY ec.is_fixed;

-- ======================================================
-- CUSTOMER SEGMENTS
-- ======================================================

-- Revenue by Customer Business Size
SELECT 
    c.business_size, 
    SUM(t.amount) AS total_revenue,
    COUNT(DISTINCT c.id) AS customer_count,
    SUM(t.amount) / COUNT(DISTINCT c.id) AS average_revenue_per_customer
FROM transactions t
JOIN customers c ON t.customer_id = c.id
WHERE t.type = 'revenue'
AND YEAR(t.transaction_date) = YEAR(CURRENT_DATE())
GROUP BY c.business_size
ORDER BY total_revenue DESC;

-- Customer Count by Segment
SELECT 
    cs.segment_name, 
    COUNT(c.id) AS customer_count,
    (COUNT(c.id) / (SELECT COUNT(*) FROM customers)) * 100 AS percentage
FROM customers c
JOIN customer_segments cs ON c.segment_id = cs.id
GROUP BY cs.segment_name
ORDER BY customer_count DESC;

-- ======================================================
-- SALES FUNNEL
-- ======================================================

-- Sales Funnel Conversion Rates
SELECT 
    ss.stage_name,
    COUNT(sfe.id) AS entries,
    SUM(CASE WHEN sfe.converted = TRUE THEN 1 ELSE 0 END) AS conversions,
    (SUM(CASE WHEN sfe.converted = TRUE THEN 1 ELSE 0 END) / COUNT(sfe.id)) * 100 AS conversion_rate
FROM sales_funnel_entries sfe
JOIN sales_stages ss ON sfe.stage_id = ss.id
WHERE sfe.entry_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
GROUP BY ss.stage_name, ss.stage_order
ORDER BY ss.stage_order;

-- Average Deal Size by Stage
SELECT 
    ss.stage_name,
    AVG(sfe.value) AS average_deal_size,
    SUM(sfe.value) AS total_potential_value
FROM sales_funnel_entries sfe
JOIN sales_stages ss ON sfe.stage_id = ss.id
WHERE sfe.entry_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
GROUP BY ss.stage_name, ss.stage_order
ORDER BY ss.stage_order;

-- Sales Cycle Length (Average days in each stage)
SELECT 
    ss.stage_name,
    AVG(DATEDIFF(COALESCE(sfe.exit_date, CURRENT_DATE()), sfe.entry_date)) AS avg_days_in_stage
FROM sales_funnel_entries sfe
JOIN sales_stages ss ON sfe.stage_id = ss.id
GROUP BY ss.stage_name, ss.stage_order
ORDER BY ss.stage_order;

-- ======================================================
-- CASH FLOW TIMELINE
-- ======================================================

-- Cash Flow Projections vs Actuals
SELECT 
    projection_date,
    projected_inflow,
    actual_inflow,
    (actual_inflow - projected_inflow) AS inflow_variance,
    projected_outflow,
    actual_outflow,
    (actual_outflow - projected_outflow) AS outflow_variance,
    (projected_inflow - projected_outflow) AS projected_net,
    (actual_inflow - actual_outflow) AS actual_net
FROM cashflow_projections
WHERE projection_date <= CURRENT_DATE()
ORDER BY projection_date;

-- Future Cash Flow Projections
SELECT 
    projection_date,
    projected_inflow,
    projected_outflow,
    (projected_inflow - projected_outflow) AS projected_net,
    SUM(projected_inflow - projected_outflow) OVER (ORDER BY projection_date) AS cumulative_projected_net
FROM cashflow_projections
WHERE projection_date > CURRENT_DATE()
ORDER BY projection_date;

-- ======================================================
-- KPI METRICS
-- ======================================================

-- KPI Performance against Targets
SELECT 
    metric_name,
    metric_value,
    target_value,
    (metric_value - target_value) AS variance,
    ((metric_value - target_value) / target_value) * 100 AS percent_variance,
    CASE 
        WHEN metric_type = 'percentage' OR metric_type = 'currency' OR metric_type = 'number' THEN
            CASE
                WHEN metric_value >= target_value THEN 'On Target'
                WHEN metric_value >= (target_value * 0.9) THEN 'Near Target'
                ELSE 'Below Target'
            END
        WHEN metric_type = 'ratio' THEN
            CASE
                WHEN metric_name IN ('Current Ratio', 'Quick Ratio') AND metric_value >= target_value THEN 'On Target'
                WHEN metric_name IN ('Current Ratio', 'Quick Ratio') AND metric_value >= (target_value * 0.9) THEN 'Near Target'
                WHEN metric_name IN ('Current Ratio', 'Quick Ratio') AND metric_value < (target_value * 0.9) THEN 'Below Target'
                WHEN metric_name IN ('Cost-Income Ratio', 'Cash Conversion Cycle') AND metric_value <= target_value THEN 'On Target'
                WHEN metric_name IN ('Cost-Income Ratio', 'Cash Conversion Cycle') AND metric_value <= (target_value * 1.1) THEN 'Near Target'
                ELSE 'Below Target'
            END
        ELSE 'Unknown Metric Type'
    END AS status
FROM kpi_metrics
WHERE metric_date = (SELECT MAX(metric_date) FROM kpi_metrics)
ORDER BY metric_name;

-- ======================================================
-- TRANSACTION QUERIES
-- ======================================================

-- Recent Transactions (Last 30 days)
SELECT 
    t.transaction_date,
    t.description,
    t.amount,
    t.type,
    CASE 
        WHEN t.type = 'revenue' THEN (SELECT category_name FROM revenue_categories WHERE id = t.category_id)
        WHEN t.type = 'expense' THEN (SELECT category_name FROM expense_categories WHERE id = t.category_id)
    END AS category,
    CASE 
        WHEN t.customer_id IS NOT NULL THEN (SELECT name FROM customers WHERE id = t.customer_id)
        ELSE NULL
    END AS customer,
    t.recurring
FROM transactions t
WHERE t.transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
ORDER BY t.transaction_date DESC;

-- Upcoming Recurring Transactions (Next 30 days)
SELECT 
    t.description,
    t.amount,
    t.type,
    t.recurring_frequency,
    CASE 
        WHEN t.type = 'revenue' THEN (SELECT category_name FROM revenue_categories WHERE id = t.category_id)
        WHEN t.type = 'expense' THEN (SELECT category_name FROM expense_categories WHERE id = t.category_id)
    END AS category,
    CASE 
        WHEN t.customer_id IS NOT NULL THEN (SELECT name FROM customers WHERE id = t.customer_id)
        ELSE NULL
    END AS customer,
    CASE
        WHEN t.recurring_frequency = 'daily' THEN DATE_ADD(t.transaction_date, INTERVAL 1 DAY)
        WHEN t.recurring_frequency = 'weekly' THEN DATE_ADD(t.transaction_date, INTERVAL 1 WEEK)
        WHEN t.recurring_frequency = 'monthly' THEN DATE_ADD(t.transaction_date, INTERVAL 1 MONTH)
        WHEN t.recurring_frequency = 'quarterly' THEN DATE_ADD(t.transaction_date, INTERVAL 3 MONTH)
        WHEN t.recurring_frequency = 'annually' THEN DATE_ADD(t.transaction_date, INTERVAL 1 YEAR)
    END AS next_due_date
FROM transactions t
WHERE t.recurring = TRUE
AND CASE
    WHEN t.recurring_frequency = 'daily' THEN DATE_ADD(t.transaction_date, INTERVAL 1 DAY)
    WHEN t.recurring_frequency = 'weekly' THEN DATE_ADD(t.transaction_date, INTERVAL 1 WEEK)
    WHEN t.recurring_frequency = 'monthly' THEN DATE_ADD(t.transaction_date, INTERVAL 1 MONTH)
    WHEN t.recurring_frequency = 'quarterly' THEN DATE_ADD(t.transaction_date, INTERVAL 3 MONTH)
    WHEN t.recurring_frequency = 'annually' THEN DATE_ADD(t.transaction_date, INTERVAL 1 YEAR)
END BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), INTERVAL 30 DAY)
ORDER BY next_due_date; 