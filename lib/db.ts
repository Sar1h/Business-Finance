import { FinancialSummary, MonthlyData, CustomerSegment, SalesFunnelData, CashflowData, KpiMetric, Transaction, CustomerGrowth, CustomerLifetimeValue, RevenueByCustomerAge, RecurringRevenue, ExpenseTrend, DealVelocity, CustomerProfitability } from './types';
import mysql from 'mysql2/promise';

// Create a connection pool
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: parseInt(process.env.DB_PORT || '3306'),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test the connection pool
pool.getConnection()
  .then(connection => {
    console.log('Database connection pool initialized');
    connection.release();
  })
  .catch(err => {
    console.error('Error initializing database pool:', err);
  });

/**
 * Execute a SQL query with parameters
 * @param {string} sql - The SQL query to execute
 * @param {Array} params - The parameters for the query
 * @returns {Promise<Array>} - Query results
 */
async function query<T>(sql: string, params: any[] = []): Promise<T[]> {
  try {
    // Use query instead of execute for better parameter handling
    const [rows] = await pool.query(sql, params);
    return rows as T[];
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
}

/**
 * Get the current month's financial summary
 * @returns {Promise<FinancialSummary>} - Financial summary
 */
export async function getFinancialSummary(): Promise<FinancialSummary> {
  const currentMonth = new Date().getMonth() + 1;
  const currentYear = new Date().getFullYear();
  
  // Get monthly revenue
  const revenueQuery = `
    SELECT SUM(amount) as monthly_revenue
    FROM transactions
    WHERE type = 'revenue'
    AND MONTH(transaction_date) = ?
    AND YEAR(transaction_date) = ?
  `;
  
  // Get monthly expenses
  const expensesQuery = `
    SELECT SUM(amount) as monthly_expenses
    FROM transactions
    WHERE type = 'expense'
    AND MONTH(transaction_date) = ?
    AND YEAR(transaction_date) = ?
  `;
  
  // Get cash balance
  const cashBalanceQuery = `
    SELECT 
      (SELECT SUM(amount) FROM transactions WHERE type = 'revenue') - 
      (SELECT SUM(amount) FROM transactions WHERE type = 'expense') 
      as cash_balance
  `;
  
  // Previous month for comparison
  const prevMonth = currentMonth === 1 ? 12 : currentMonth - 1;
  const prevYear = currentMonth === 1 ? currentYear - 1 : currentYear;
  
  // Get previous month revenue
  const prevRevenueQuery = `
    SELECT SUM(amount) as prev_monthly_revenue
    FROM transactions
    WHERE type = 'revenue'
    AND MONTH(transaction_date) = ?
    AND YEAR(transaction_date) = ?
  `;
  
  // Get previous month expenses
  const prevExpensesQuery = `
    SELECT SUM(amount) as prev_monthly_expenses
    FROM transactions
    WHERE type = 'expense'
    AND MONTH(transaction_date) = ?
    AND YEAR(transaction_date) = ?
  `;
  
  try {
    const [revenue] = await query<{ monthly_revenue: number }>(revenueQuery, [currentMonth, currentYear]);
    const [expenses] = await query<{ monthly_expenses: number }>(expensesQuery, [currentMonth, currentYear]);
    const [cashBalance] = await query<{ cash_balance: number }>(cashBalanceQuery);
    const [prevRevenue] = await query<{ prev_monthly_revenue: number }>(prevRevenueQuery, [prevMonth, prevYear]);
    const [prevExpenses] = await query<{ prev_monthly_expenses: number }>(prevExpensesQuery, [prevMonth, prevYear]);
    
    // Calculate net profit
    const monthlyRevenue = revenue.monthly_revenue || 0;
    const monthlyExpenses = expenses.monthly_expenses || 0;
    const netProfit = monthlyRevenue - monthlyExpenses;
    
    // Calculate percentage changes
    const prevMonthlyRevenue = prevRevenue.prev_monthly_revenue || 0;
    const prevMonthlyExpenses = prevExpenses.prev_monthly_expenses || 0;
    const prevNetProfit = prevMonthlyRevenue - prevMonthlyExpenses;
    
    const revenueChange = prevMonthlyRevenue ? ((monthlyRevenue - prevMonthlyRevenue) / prevMonthlyRevenue) * 100 : 0;
    const expensesChange = prevMonthlyExpenses ? ((monthlyExpenses - prevMonthlyExpenses) / prevMonthlyExpenses) * 100 : 0;
    const netProfitChange = prevNetProfit ? ((netProfit - prevNetProfit) / prevNetProfit) * 100 : 0;
    
    return {
      monthlyRevenue,
      monthlyExpenses,
      netProfit,
      cashBalance: cashBalance.cash_balance || 0,
      revenueChange,
      expensesChange,
      netProfitChange
    };
  } catch (error) {
    console.error('Error getting financial summary:', error);
    throw error;
  }
}

/**
 * Get the last 6 months of revenue and expenses data
 * @returns {Promise<MonthlyData[]>} - Monthly data
 */
export async function getMonthlyRevenueExpenses(): Promise<MonthlyData[]> {
  const sql = `
    SELECT 
      DATE_FORMAT(transaction_date, '%Y-%m') AS month,
      SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) AS revenue,
      SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS expense
    FROM transactions
    WHERE transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
    ORDER BY month
  `;
  
  try {
    return await query<MonthlyData>(sql);
  } catch (error) {
    console.error('Error getting monthly data:', error);
    throw error;
  }
}

/**
 * Get customer segments distribution
 * @returns {Promise<CustomerSegment[]>} - Customer segments data
 */
export async function getCustomerSegments(): Promise<CustomerSegment[]> {
  const sql = `
    SELECT 
      c.business_size, 
      COUNT(c.id) AS count,
      SUM(c.lifetime_value) AS total_value
    FROM customers c
    GROUP BY c.business_size
    ORDER BY total_value DESC
  `;
  
  try {
    return await query<CustomerSegment>(sql);
  } catch (error) {
    console.error('Error getting customer segments:', error);
    throw error;
  }
}

/**
 * Get sales funnel data
 * @returns {Promise<SalesFunnelData[]>} - Sales funnel data
 */
export async function getSalesFunnel(): Promise<SalesFunnelData[]> {
  const sql = `
    SELECT 
      ss.stage_name,
      ss.stage_order,
      COUNT(sfe.id) AS entries,
      SUM(CASE WHEN sfe.converted = TRUE THEN 1 ELSE 0 END) AS conversions,
      (SUM(CASE WHEN sfe.converted = TRUE THEN 1 ELSE 0 END) / COUNT(sfe.id)) * 100 AS conversion_rate
    FROM sales_funnel_entries sfe
    JOIN sales_stages ss ON sfe.stage_id = ss.id
    GROUP BY ss.stage_name, ss.stage_order
    ORDER BY ss.stage_order
  `;
  
  try {
    return await query<SalesFunnelData>(sql);
  } catch (error) {
    console.error('Error getting sales funnel:', error);
    throw error;
  }
}

/**
 * Get cashflow timeline data
 * @returns {Promise<CashflowData[]>} - Cashflow data
 */
export async function getCashflowTimeline(): Promise<CashflowData[]> {
  const sql = `
    SELECT 
      projection_date,
      projected_inflow,
      projected_outflow,
      actual_inflow,
      actual_outflow,
      (projected_inflow - projected_outflow) AS projected_net,
      (actual_inflow - actual_outflow) AS actual_net
    FROM cashflow_projections
    ORDER BY projection_date
  `;
  
  try {
    return await query<CashflowData>(sql);
  } catch (error) {
    console.error('Error getting cashflow timeline:', error);
    throw error;
  }
}

/**
 * Get KPI metrics data
 * @returns {Promise<KpiMetric[]>} - KPI metrics
 */
export async function getKpiMetrics(): Promise<KpiMetric[]> {
  const sql = `
    SELECT 
      metric_name,
      metric_value,
      target_value,
      metric_type,
      description
    FROM kpi_metrics
    WHERE metric_date = (SELECT MAX(metric_date) FROM kpi_metrics)
  `;
  
  try {
    return await query<KpiMetric>(sql);
  } catch (error) {
    console.error('Error getting KPI metrics:', error);
    throw error;
  }
}

/**
 * Get recent transactions
 * @param {number} limit - Number of transactions to return
 * @returns {Promise<Transaction[]>} - Recent transactions
 */
export async function getRecentTransactions(limit: number = 10): Promise<Transaction[]> {
  const sql = `
    SELECT 
      t.id,
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
      END AS customer
    FROM transactions t
    ORDER BY t.transaction_date DESC
    LIMIT ?
  `;
  
  try {
    // Ensure limit is a positive integer and pass it directly
    const sanitizedLimit = Math.max(1, Math.floor(Number(limit)));
    return await query<Transaction>(sql, [sanitizedLimit]);
  } catch (error) {
    console.error('Error getting recent transactions:', error);
    throw error;
  }
}

/**
 * Get customer growth rate data
 * @returns {Promise<CustomerGrowth[]>} - Customer growth data
 */
export async function getCustomerGrowthRate(): Promise<CustomerGrowth[]> {
  const sql = `
    SELECT 
      DATE_FORMAT(acquisition_date, '%Y-%m') as month,
      COUNT(*) as new_customers,
      COUNT(*) / (
          SELECT COUNT(*) 
          FROM customers 
          WHERE acquisition_date < DATE_FORMAT(c.acquisition_date, '%Y-%m-01')
      ) * 100 as growth_rate
    FROM customers c
    GROUP BY DATE_FORMAT(acquisition_date, '%Y-%m')
    ORDER BY month
  `;
  
  try {
    return await query<CustomerGrowth>(sql);
  } catch (error) {
    console.error('Error getting customer growth rate:', error);
    throw error;
  }
}

/**
 * Get customer lifetime value analysis
 * @returns {Promise<CustomerLifetimeValue[]>} - Customer LTV data
 */
export async function getCustomerLifetimeValue(): Promise<CustomerLifetimeValue[]> {
  const sql = `
    SELECT 
      business_size,
      AVG(lifetime_value) as avg_ltv,
      MIN(lifetime_value) as min_ltv,
      MAX(lifetime_value) as max_ltv,
      STDDEV(lifetime_value) as ltv_stddev
    FROM customers
    GROUP BY business_size
  `;
  
  try {
    return await query<CustomerLifetimeValue>(sql);
  } catch (error) {
    console.error('Error getting customer lifetime value:', error);
    throw error;
  }
}

/**
 * Get revenue by customer age
 * @returns {Promise<RevenueByCustomerAge[]>} - Revenue by customer age data
 */
export async function getRevenueByCustomerAge(): Promise<RevenueByCustomerAge[]> {
  const sql = `
    SELECT 
      CASE 
        WHEN DATEDIFF(CURRENT_DATE, acquisition_date) <= 90 THEN '0-3 months'
        WHEN DATEDIFF(CURRENT_DATE, acquisition_date) <= 180 THEN '3-6 months'
        WHEN DATEDIFF(CURRENT_DATE, acquisition_date) <= 365 THEN '6-12 months'
        ELSE 'Over 12 months'
      END as customer_age,
      SUM(t.amount) as total_revenue,
      COUNT(DISTINCT t.customer_id) as customer_count,
      SUM(t.amount) / COUNT(DISTINCT t.customer_id) as avg_revenue_per_customer
    FROM transactions t
    JOIN customers c ON t.customer_id = c.id
    WHERE t.type = 'revenue'
    GROUP BY 
      CASE 
        WHEN DATEDIFF(CURRENT_DATE, acquisition_date) <= 90 THEN '0-3 months'
        WHEN DATEDIFF(CURRENT_DATE, acquisition_date) <= 180 THEN '3-6 months'
        WHEN DATEDIFF(CURRENT_DATE, acquisition_date) <= 365 THEN '6-12 months'
        ELSE 'Over 12 months'
      END
    ORDER BY customer_age
  `;
  
  try {
    return await query<RevenueByCustomerAge>(sql);
  } catch (error) {
    console.error('Error getting revenue by customer age:', error);
    throw error;
  }
}

/**
 * Get recurring vs non-recurring revenue analysis
 * @returns {Promise<RecurringRevenue[]>} - Recurring revenue data
 */
export async function getRecurringRevenue(): Promise<RecurringRevenue[]> {
  const sql = `
    SELECT 
      DATE_FORMAT(transaction_date, '%Y-%m') as month,
      SUM(CASE WHEN recurring = TRUE THEN amount ELSE 0 END) as recurring_revenue,
      SUM(CASE WHEN recurring = FALSE THEN amount ELSE 0 END) as non_recurring_revenue,
      COUNT(CASE WHEN recurring = TRUE THEN 1 END) as recurring_transactions,
      COUNT(CASE WHEN recurring = FALSE THEN 1 END) as non_recurring_transactions
    FROM transactions
    WHERE type = 'revenue'
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
    ORDER BY month
  `;
  
  try {
    return await query<RecurringRevenue>(sql);
  } catch (error) {
    console.error('Error getting recurring revenue:', error);
    throw error;
  }
}

/**
 * Get expense trends by category
 * @returns {Promise<ExpenseTrend[]>} - Expense trend data
 */
export async function getExpenseTrends(): Promise<ExpenseTrend[]> {
  const sql = `
    SELECT 
      ec.category_name,
      DATE_FORMAT(t.transaction_date, '%Y-%m') as month,
      SUM(t.amount) as total_expense,
      SUM(t.amount) / (
        SELECT SUM(amount) 
        FROM transactions 
        WHERE type = 'expense' 
        AND DATE_FORMAT(transaction_date, '%Y-%m') = DATE_FORMAT(t.transaction_date, '%Y-%m')
      ) * 100 as percentage_of_monthly_expense
    FROM transactions t
    JOIN expense_categories ec ON t.category_id = ec.id
    WHERE t.type = 'expense'
    GROUP BY ec.category_name, DATE_FORMAT(t.transaction_date, '%Y-%m')
    ORDER BY month, total_expense DESC
  `;
  
  try {
    return await query<ExpenseTrend>(sql);
  } catch (error) {
    console.error('Error getting expense trends:', error);
    throw error;
  }
}

/**
 * Get deal velocity metrics
 * @returns {Promise<DealVelocity[]>} - Deal velocity data
 */
export async function getDealVelocity(): Promise<DealVelocity[]> {
  const sql = `
    SELECT 
      ss.stage_name,
      COUNT(sfe.id) as total_deals,
      AVG(DATEDIFF(COALESCE(sfe.exit_date, CURRENT_DATE), sfe.entry_date)) as avg_days_in_stage,
      SUM(sfe.value) / COUNT(sfe.id) as avg_deal_value,
      SUM(CASE WHEN sfe.converted = TRUE THEN 1 ELSE 0 END) / COUNT(sfe.id) * 100 as conversion_rate
    FROM sales_funnel_entries sfe
    JOIN sales_stages ss ON sfe.stage_id = ss.id
    WHERE sfe.entry_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
    GROUP BY ss.stage_name, ss.stage_order
    ORDER BY ss.stage_order
  `;
  
  try {
    return await query<DealVelocity>(sql);
  } catch (error) {
    console.error('Error getting deal velocity:', error);
    throw error;
  }
}

/**
 * Get customer profitability analysis
 * @returns {Promise<CustomerProfitability[]>} - Customer profitability data
 */
export async function getCustomerProfitability(): Promise<CustomerProfitability[]> {
  const sql = `
    SELECT 
      c.name as customer_name,
      c.business_size,
      SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END) as total_revenue,
      SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END) as total_cost,
      SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE -t.amount END) as profit,
      (SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE -t.amount END) / 
       SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END)) * 100 as profit_margin
    FROM customers c
    LEFT JOIN transactions t ON c.id = t.customer_id
    GROUP BY c.id, c.name, c.business_size
    HAVING total_revenue > 0
    ORDER BY profit_margin DESC
  `;
  
  try {
    return await query<CustomerProfitability>(sql);
  } catch (error) {
    console.error('Error getting customer profitability:', error);
    throw error;
  }
}

export {
  query
}; 