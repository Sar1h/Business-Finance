export interface FinancialSummary {
  monthlyRevenue: number;
  monthlyExpenses: number;
  netProfit: number;
  cashBalance: number;
  revenueChange: number;
  expensesChange: number;
  netProfitChange: number;
}

export interface MonthlyData {
  month: string;
  revenue: number;
  expense: number;
}

export interface CustomerSegment {
  business_size: string;
  count: number;
  total_value: number;
}

export interface SalesFunnelData {
  stage_name: string;
  stage_order: number;
  entries: number;
  conversions: number;
  conversion_rate: number;
}

export interface CashflowData {
  projection_date: string;
  projected_inflow: number;
  projected_outflow: number;
  actual_inflow: number;
  actual_outflow: number;
  projected_net: number;
  actual_net: number;
}

export interface KpiMetric {
  metric_name: string;
  metric_value: number;
  target_value: number;
  metric_type: string;
  description: string;
}

export interface Transaction {
  id: number;
  transaction_date: string;
  description: string;
  amount: number;
  type: 'revenue' | 'expense';
  category: string;
  customer?: string;
  recurring: boolean;
}

// New types for additional analytics
export interface CustomerGrowth {
  month: string;
  new_customers: number;
  growth_rate: number;
}

export interface CustomerLifetimeValue {
  business_size: string;
  avg_ltv: number;
  min_ltv: number;
  max_ltv: number;
  ltv_stddev: number;
}

export interface RevenueByCustomerAge {
  customer_age: string;
  total_revenue: number;
  customer_count: number;
  avg_revenue_per_customer: number;
}

export interface RecurringRevenue {
  month: string;
  recurring_revenue: number;
  non_recurring_revenue: number;
  recurring_transactions: number;
  non_recurring_transactions: number;
}

export interface ExpenseTrend {
  category_name: string;
  month: string;
  total_expense: number;
  percentage_of_monthly_expense: number;
}

export interface DealVelocity {
  stage_name: string;
  total_deals: number;
  avg_days_in_stage: number;
  avg_deal_value: number;
  conversion_rate: number;
}

export interface CustomerProfitability {
  customer_name: string;
  business_size: string;
  total_revenue: number;
  total_cost: number;
  profit: number;
  profit_margin: number;
} 