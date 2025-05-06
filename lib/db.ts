import { FinancialSummary, MonthlyData, CustomerSegment, SalesFunnelData, CashflowData, KpiMetric, Transaction, CustomerGrowth, CustomerLifetimeValue, RevenueByCustomerAge, RecurringRevenue, ExpenseTrend, DealVelocity, CustomerProfitability, CustomerInfo } from './types';
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
 * Get the current month's financial summary using the updated schema
 * @returns {Promise<FinancialSummary>} - Financial summary
 */
export async function getFinancialSummary(): Promise<FinancialSummary> {
  const currentMonth = new Date().getMonth() + 1;
  const currentYear = new Date().getFullYear();
  
  // Get monthly revenue using the transactions table with type 'revenue'
  const revenueQuery = `
    SELECT SUM(amount) as monthly_revenue
    FROM transactions
    WHERE type = 'revenue'
    AND MONTH(transaction_date) = ?
    AND YEAR(transaction_date) = ?
  `;
  
  // Get monthly expenses using the transactions table with type 'expense'
  const expensesQuery = `
    SELECT SUM(amount) as monthly_expenses
    FROM transactions
    WHERE type = 'expense'
    AND MONTH(transaction_date) = ?
    AND YEAR(transaction_date) = ?
  `;
  
  // Get cash balance as the difference between total revenue and expenses
  const cashBalanceQuery = `
    SELECT 
      (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'revenue') - 
      (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'expense') 
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
 * Get the last 6 months of revenue and expenses data from transactions table
 * @returns {Promise<MonthlyData[]>} - Monthly data
 */
export async function getMonthlyRevenueExpenses(): Promise<MonthlyData[]> {
  const sql = `
    SELECT 
      DATE_FORMAT(transaction_date, '%Y-%m') AS month,
      SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) AS revenue,
      SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS expense
    FROM transactions
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
    ORDER BY month
  `;
  
  try {
    const result = await query<MonthlyData>(sql);
    console.log("Monthly data found:", result.length, "records");
    return result;
  } catch (error) {
    console.error('Error getting monthly data:', error);
    throw error;
  }
}

/**
 * Get customer segments distribution from customers table
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
 * Get sales funnel data from sales_pipeline table
 * @returns {Promise<SalesFunnelData[]>} - Sales funnel data
 */
export async function getSalesFunnel(): Promise<SalesFunnelData[]> {
  const sql = `
    SELECT 
      stage_name,
      stage_order,
      COUNT(id) AS entries,
      SUM(CASE WHEN exit_date IS NOT NULL THEN 1 ELSE 0 END) AS conversions,
      (SUM(CASE WHEN exit_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(id)) * 100 AS conversion_rate
    FROM sales_pipeline
    GROUP BY stage_name, stage_order
    ORDER BY stage_order
  `;
  
  try {
    return await query<SalesFunnelData>(sql);
  } catch (error) {
    console.error('Error getting sales funnel:', error);
    throw error;
  }
}

/**
 * Get cashflow timeline data from cashflow table
 * @param {number|null} customerId - Optional customer ID to filter data
 * @returns {Promise<CashflowData[]>} - Cashflow data
 */
export async function getCashflowTimeline(customerId?: number): Promise<CashflowData[]> {
  // If customerId is provided, we'll calculate cashflow from transactions
  if (customerId) {
    const sql = `
      SELECT 
        DATE_FORMAT(transaction_date, '%Y-%m-01') as projection_date,
        SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) as projected_inflow,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as projected_outflow,
        SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) as actual_inflow,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as actual_outflow,
        SUM(CASE WHEN type = 'revenue' THEN amount ELSE -amount END) AS projected_net,
        SUM(CASE WHEN type = 'revenue' THEN amount ELSE -amount END) AS actual_net
      FROM transactions
      WHERE customer_id = ?
      GROUP BY DATE_FORMAT(transaction_date, '%Y-%m-01')
      ORDER BY projection_date
    `;
    
    try {
      const result = await query<CashflowData>(sql, [customerId]);
      console.log(`Found ${result.length} customer-specific cashflow timeline records for customer ${customerId}`);
      return result;
    } catch (error) {
      console.error('Error getting customer cashflow timeline:', error);
      throw error;
    }
  } else {
    // Use the original query for all customers
    const sql = `
      SELECT 
        period_date as projection_date,
        projected_inflow,
        projected_outflow,
        actual_inflow,
        actual_outflow,
        (projected_inflow - projected_outflow) AS projected_net,
        (actual_inflow - actual_outflow) AS actual_net
      FROM cashflow
      ORDER BY period_date
    `;
    
    try {
      const result = await query<CashflowData>(sql);
      console.log(`Found ${result.length} cashflow timeline records for all customers`);
      if (result.length === 0) {
        console.log('No cashflow data found - you may need to run the /api/add-cashflow-test-data endpoint');
      }
      return result;
    } catch (error) {
      console.error('Error getting cashflow timeline:', error);
      throw error;
    }
  }
}

/**
 * Get KPI metrics data
 * @param {number|null} customerId - Optional customer ID to filter data
 * @returns {Promise<KpiMetric[]>} - KPI metrics
 */
export async function getKpiMetrics(customerId?: number): Promise<KpiMetric[]> {
  // Add customer filter if customerId is provided
  const customerFilter = customerId ? `AND customer_id = ${customerId}` : '';
  
  // Calculate profit margin from transactions
  const profitMarginSql = `
    SELECT 
      'Profit Margin' as metric_name,
      (SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) - 
       SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END)) / 
       NULLIF(SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END), 0) * 100 as metric_value,
      80 as target_value,
      'percentage' as metric_type,
      'Net profit as a percentage of revenue' as description
    FROM transactions
    WHERE transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
    ${customerFilter}
  `;
  
  // Calculate customer retention rate (only relevant for all customers)
  let customerRetentionSql;
  if (customerId) {
    customerRetentionSql = `
      SELECT 
        'Customer Retention' as metric_name,
        CASE 
          WHEN EXISTS (
            SELECT 1 FROM transactions 
            WHERE customer_id = ${customerId} 
            AND transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
          ) THEN 100
          ELSE 0
        END as metric_value,
        90 as target_value,
        'percentage' as metric_type,
        'Customer active status in last 3 months' as description
    `;
  } else {
    customerRetentionSql = `
      SELECT 
        'Customer Retention' as metric_name,
        COUNT(DISTINCT customer_id) * 100 / 
        (SELECT COUNT(DISTINCT id) FROM customers) as metric_value,
        90 as target_value,
        'percentage' as metric_type,
        'Percentage of customers with recent activity' as description
      FROM transactions
      WHERE type = 'revenue'
      AND transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
    `;
  }
  
  // Calculate average deal size
  const avgDealSizeSql = `
    SELECT 
      'Average Deal Size' as metric_name,
      AVG(amount) as metric_value,
      10000 as target_value,
      'currency' as metric_type,
      'Average revenue transaction amount' as description
    FROM transactions
    WHERE type = 'revenue'
    AND transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
    ${customerFilter}
  `;
  
  // Calculate cash runway (only relevant for all customers, for a customer use lifetime value instead)
  let cashRunwaySql;
  if (customerId) {
    cashRunwaySql = `
      SELECT 
        'Customer Value' as metric_name,
        COALESCE(
          (SELECT lifetime_value FROM customers WHERE id = ${customerId}),
          (SELECT SUM(amount) FROM transactions WHERE type = 'revenue' AND customer_id = ${customerId})
        ) as metric_value,
        5000 as target_value,
        'currency' as metric_type,
        'Total customer lifetime value' as description
    `;
  } else {
    cashRunwaySql = `
      SELECT 
        'Cash Runway' as metric_name,
        (SELECT 
          (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'revenue') - 
          (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'expense')
        ) / 
        (
          SELECT AVG(monthly_expense) FROM (
            SELECT 
              YEAR(transaction_date) as year, 
              MONTH(transaction_date) as month, 
              SUM(amount) as monthly_expense
            FROM transactions
            WHERE type = 'expense'
            AND transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
            GROUP BY YEAR(transaction_date), MONTH(transaction_date)
          ) as monthly_expenses
        ) as metric_value,
        12 as target_value,
        'months' as metric_type,
        'Months of operation possible with current cash' as description
    `;
  }
  
  try {
    const [profitMargin] = await query<KpiMetric>(profitMarginSql);
    const [customerRetention] = await query<KpiMetric>(customerRetentionSql);
    const [avgDealSize] = await query<KpiMetric>(avgDealSizeSql);
    const [cashRunway] = await query<KpiMetric>(cashRunwaySql);
    
    // Log to help with debugging
    if (customerId) {
      console.log(`KPI metrics for customer ${customerId}:`, {
        profitMargin: profitMargin?.metric_value,
        customerRetention: customerRetention?.metric_value,
        avgDealSize: avgDealSize?.metric_value,
        customerValue: cashRunway?.metric_value
      });
    }
    
    return [profitMargin, customerRetention, avgDealSize, cashRunway];
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
      c.category_name as category,
      cu.name as customer,
      t.recurring
    FROM transactions t
    LEFT JOIN categories c ON t.category_id = c.id
    LEFT JOIN customers cu ON t.customer_id = cu.id
    ORDER BY t.transaction_date DESC
    LIMIT ?
  `;
  
  try {
    return await query<Transaction>(sql, [limit]);
  } catch (error) {
    console.error('Error getting recent transactions:', error);
    throw error;
  }
}

/**
 * Get customer growth rate over time
 * @returns {Promise<CustomerGrowth[]>} - Customer growth data
 */
export async function getCustomerGrowthRate(): Promise<CustomerGrowth[]> {
  const sql = `
    SELECT 
      DATE_FORMAT(acquisition_date, '%Y-%m') AS month,
      COUNT(id) AS new_customers,
      0 AS growth_rate
    FROM customers
    WHERE acquisition_date IS NOT NULL
    GROUP BY DATE_FORMAT(acquisition_date, '%Y-%m')
    ORDER BY month
    LIMIT 12
  `;
  
  try {
    const results = await query<CustomerGrowth>(sql);
    
    // Calculate growth rate
    for (let i = 1; i < results.length; i++) {
      const prevCustomers = results[i-1].new_customers;
      const currentCustomers = results[i].new_customers;
      results[i].growth_rate = prevCustomers ? ((currentCustomers - prevCustomers) / prevCustomers) * 100 : 0;
    }
    
    return results;
  } catch (error) {
    console.error('Error getting customer growth rate:', error);
    throw error;
  }
}

/**
 * Get customer lifetime value by business size
 * @returns {Promise<CustomerLifetimeValue[]>} - Customer LTV data
 */
export async function getCustomerLifetimeValue(): Promise<CustomerLifetimeValue[]> {
  const sql = `
    SELECT 
      business_size,
      AVG(lifetime_value) AS avg_ltv,
      MIN(lifetime_value) AS min_ltv,
      MAX(lifetime_value) AS max_ltv,
      STDDEV(lifetime_value) AS ltv_stddev
    FROM customers
    GROUP BY business_size
    ORDER BY avg_ltv DESC
  `;
  
  try {
    return await query<CustomerLifetimeValue>(sql);
  } catch (error) {
    console.error('Error getting customer lifetime value:', error);
    throw error;
  }
}

/**
 * Get revenue by customer age (how long they've been customers)
 * @returns {Promise<RevenueByCustomerAge[]>} - Revenue by customer age data
 */
export async function getRevenueByCustomerAge(): Promise<RevenueByCustomerAge[]> {
  const sql = `
    SELECT 
      CASE 
        WHEN DATEDIFF(CURRENT_DATE, c.acquisition_date) <= 90 THEN 'Less than 3 months'
        WHEN DATEDIFF(CURRENT_DATE, c.acquisition_date) <= 180 THEN '3-6 months'
        WHEN DATEDIFF(CURRENT_DATE, c.acquisition_date) <= 365 THEN '6-12 months'
        ELSE 'Over 12 months'
      END AS customer_age,
      SUM(t.amount) AS total_revenue,
      COUNT(DISTINCT c.id) AS customer_count,
      SUM(t.amount) / COUNT(DISTINCT c.id) AS avg_revenue_per_customer
    FROM transactions t
    JOIN customers c ON t.customer_id = c.id
    WHERE t.type = 'revenue'
    AND c.acquisition_date IS NOT NULL
    GROUP BY 
      CASE 
        WHEN DATEDIFF(CURRENT_DATE, c.acquisition_date) <= 90 THEN 'Less than 3 months'
        WHEN DATEDIFF(CURRENT_DATE, c.acquisition_date) <= 180 THEN '3-6 months'
        WHEN DATEDIFF(CURRENT_DATE, c.acquisition_date) <= 365 THEN '6-12 months'
        ELSE 'Over 12 months'
      END
    ORDER BY 
      CASE 
        WHEN customer_age = 'Less than 3 months' THEN 1
        WHEN customer_age = '3-6 months' THEN 2
        WHEN customer_age = '6-12 months' THEN 3
        ELSE 4
      END
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
      DATE_FORMAT(transaction_date, '%Y-%m') AS month,
      SUM(CASE WHEN recurring = TRUE THEN amount ELSE 0 END) AS recurring_revenue,
      SUM(CASE WHEN recurring = FALSE THEN amount ELSE 0 END) AS non_recurring_revenue,
      COUNT(CASE WHEN recurring = TRUE THEN 1 END) AS recurring_transactions,
      COUNT(CASE WHEN recurring = FALSE THEN 1 END) AS non_recurring_transactions
    FROM transactions
    WHERE type = 'revenue'
    AND transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
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
      c.category_name,
      month_year.month_val AS month,
      SUM(t.amount) AS total_expense,
      (SUM(t.amount) / (
        SELECT SUM(amount) 
        FROM transactions 
        WHERE type = 'expense' 
        AND DATE_FORMAT(transaction_date, '%Y-%m') = month_year.month_val
      )) * 100 AS percentage_of_monthly_expense
    FROM transactions t
    JOIN categories c ON t.category_id = c.id
    JOIN (
      SELECT DISTINCT DATE_FORMAT(transaction_date, '%Y-%m') AS month_val
      FROM transactions
      WHERE transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
    ) month_year ON DATE_FORMAT(t.transaction_date, '%Y-%m') = month_year.month_val
    WHERE t.type = 'expense'
    AND t.transaction_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
    GROUP BY c.category_name, month_year.month_val
    ORDER BY month_year.month_val, total_expense DESC
  `;
  
  try {
    return await query<ExpenseTrend>(sql);
  } catch (error) {
    console.error('Error getting expense trends:', error);
    throw error;
  }
}

/**
 * Get deal velocity from sales pipeline
 * @returns {Promise<DealVelocity[]>} - Deal velocity data
 */
export async function getDealVelocity(): Promise<DealVelocity[]> {
  const sql = `
    SELECT 
      stage_name,
      MAX(stage_order) AS stage_order,
      COUNT(id) AS total_deals,
      AVG(DATEDIFF(IFNULL(exit_date, CURRENT_DATE), entry_date)) AS avg_days_in_stage,
      AVG(value) AS avg_deal_value,
      SUM(CASE WHEN exit_date IS NOT NULL THEN 1 ELSE 0 END) / COUNT(id) * 100 AS conversion_rate
    FROM sales_pipeline
    WHERE entry_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
    GROUP BY stage_name
    ORDER BY MAX(stage_order)
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
      c.name AS customer_name,
      c.business_size,
      SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END) AS total_revenue,
      SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END) AS total_cost,
      SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE -t.amount END) AS profit,
      CASE 
        WHEN SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END) > 0 
        THEN SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE -t.amount END) / 
             SUM(CASE WHEN t.type = 'revenue' THEN t.amount ELSE 0 END) * 100
        ELSE 0 
      END AS profit_margin
    FROM transactions t
    JOIN customers c ON t.customer_id = c.id
    GROUP BY c.name, c.business_size
    ORDER BY profit DESC
    LIMIT 10
  `;
  
  try {
    return await query<CustomerProfitability>(sql);
  } catch (error) {
    console.error('Error getting customer profitability:', error);
    throw error;
  }
}

/**
 * Get financial summary for a specific customer
 * @param {number} customerId - The customer ID
 * @returns {Promise<FinancialSummary>} - Customer-specific financial summary
 */
export async function getCustomerFinancialSummary(customerId: number): Promise<FinancialSummary> {
  try {
    // Get total revenue for this customer
    const revenueQuery = `
      SELECT SUM(amount) as monthly_revenue
      FROM transactions
      WHERE type = 'revenue'
      AND customer_id = ?
    `;
    
    // Get total expenses for this customer
    const expensesQuery = `
      SELECT SUM(amount) as monthly_expenses
      FROM transactions
      WHERE type = 'expense'
      AND customer_id = ?
    `;
    
    // Get cash balance for this customer (total revenue - expenses)
    const cashBalanceQuery = `
      SELECT 
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'revenue' AND customer_id = ?) - 
        (SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'expense' AND customer_id = ?) 
        as cash_balance
    `;
    
    // Get previous month data (not really needed now but keeping the same structure)
    const prevRevenueQuery = `
      SELECT COALESCE(SUM(amount), 0) as prev_monthly_revenue
      FROM transactions
      WHERE type = 'revenue'
      AND customer_id = ?
    `;
    
    const prevExpensesQuery = `
      SELECT COALESCE(SUM(amount), 0) as prev_monthly_expenses
      FROM transactions
      WHERE type = 'expense'
      AND customer_id = ?
    `;
    
    const [revenue] = await query<{ monthly_revenue: number }>(revenueQuery, [customerId]);
    const [expenses] = await query<{ monthly_expenses: number }>(expensesQuery, [customerId]);
    const [cashBalance] = await query<{ cash_balance: number }>(cashBalanceQuery, [customerId, customerId]);
    const [prevRevenue] = await query<{ prev_monthly_revenue: number }>(prevRevenueQuery, [customerId]);
    const [prevExpenses] = await query<{ prev_monthly_expenses: number }>(prevExpensesQuery, [customerId]);
    
    console.log("Customer Financial Data:", {
      customerId,
      revenue,
      expenses,
      cashBalance
    });
    
    // Calculate net profit
    const monthlyRevenue = revenue.monthly_revenue || 0;
    const monthlyExpenses = expenses.monthly_expenses || 0;
    const netProfit = monthlyRevenue - monthlyExpenses;
    
    // For now, using static values for changes as we're just showing total numbers
    const revenueChange = 0;
    const expensesChange = 0;
    const netProfitChange = 0;
    
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
    console.error('Error getting customer financial summary:', error);
    throw error;
  }
}

/**
 * Get monthly revenue & expenses for a specific customer
 * @param {number} customerId - The customer ID
 * @returns {Promise<MonthlyData[]>} - Customer-specific monthly data
 */
export async function getCustomerMonthlyData(customerId: number): Promise<MonthlyData[]> {
  const sql = `
    SELECT 
      DATE_FORMAT(transaction_date, '%Y-%m') AS month,
      SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) AS revenue,
      SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS expense
    FROM transactions
    WHERE customer_id = ?
    GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
    ORDER BY month
  `;
  
  try {
    console.log(`Getting monthly data for customer ID: ${customerId}`);
    const result = await query<MonthlyData>(sql, [customerId]);
    console.log(`Found ${result.length} monthly data records for customer`);
    return result;
  } catch (error) {
    console.error('Error getting customer monthly data:', error);
    throw error;
  }
}

/**
 * Get recent transactions for a specific customer
 * @param {number} customerId - The customer ID
 * @param {number} limit - Number of transactions to return
 * @returns {Promise<Transaction[]>} - Customer-specific transactions
 */
export async function getCustomerTransactions(customerId: number, limit: number = 5): Promise<Transaction[]> {
  const sql = `
    SELECT 
      t.id, 
      t.transaction_date, 
      t.description, 
      t.amount, 
      t.type,
      c.category_name as category,
      COALESCE(cu.name, 'Unknown') as customer,
      t.recurring
    FROM transactions t
    LEFT JOIN categories c ON t.category_id = c.id
    LEFT JOIN customers cu ON t.customer_id = cu.id
    WHERE t.customer_id = ?
    ORDER BY t.transaction_date DESC
    LIMIT ?
  `;
  
  try {
    console.log(`Getting transactions for customer ID: ${customerId}, limit: ${limit}`);
    const transactions = await query<Transaction>(sql, [customerId, limit]);
    console.log(`Found ${transactions.length} transactions`);
    return transactions;
  } catch (error) {
    console.error('Error getting customer transactions:', error);
    throw error;
  }
}

/**
 * Get all customers for dropdown
 * @returns {Promise<CustomerInfo[]>} - List of all customers
 */
export async function getAllCustomers(): Promise<CustomerInfo[]> {
  const sql = `
    SELECT 
      c.id,
      c.name,
      c.business_size,
      c.lifetime_value,
      c.acquisition_date,
      c.last_purchase_date,
      c.payment_reliability,
      c.risk_score,
      cs.segment_name
    FROM customers c
    LEFT JOIN customer_segments cs ON c.segment_id = cs.id
    ORDER BY c.name
  `;
  
  try {
    return await query<CustomerInfo>(sql);
  } catch (error) {
    console.error('Error getting customers:', error);
    throw error;
  }
}

export {
  query
}; 