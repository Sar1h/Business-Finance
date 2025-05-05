import { NextResponse } from 'next/server';
import {
  getFinancialSummary,
  getMonthlyRevenueExpenses,
  getCustomerSegments,
  getSalesFunnel,
  getCashflowTimeline,
  getKpiMetrics,
  getRecentTransactions,
  getCustomerGrowthRate,
  getCustomerLifetimeValue,
  getRevenueByCustomerAge,
  getRecurringRevenue,
  getExpenseTrends,
  getDealVelocity,
  getCustomerProfitability
} from '@/lib/db';

export async function GET() {
  // Create an object to hold our dashboard data
  const dashboardData: any = {};
  let hasErrors = false;
  const errors: string[] = [];

  // Function to safely execute a database query
  const safeQuery = async (key: string, queryFn: Function, ...args: any[]) => {
    try {
      dashboardData[key] = await queryFn(...args);
    } catch (error) {
      console.error(`Error fetching ${key}:`, error);
      dashboardData[key] = [];
      hasErrors = true;
      errors.push(`${key}: ${error instanceof Error ? error.message : String(error)}`);
    }
  };

  // Execute all queries in parallel but handle errors for each individually
  await Promise.all([
    safeQuery('financialSummary', getFinancialSummary),
    safeQuery('monthlyData', getMonthlyRevenueExpenses),
    safeQuery('customerSegments', getCustomerSegments),
    safeQuery('salesFunnel', getSalesFunnel),
    safeQuery('cashflowTimeline', getCashflowTimeline),
    safeQuery('kpiMetrics', getKpiMetrics),
    safeQuery('recentTransactions', getRecentTransactions, 5),
    safeQuery('customerGrowth', getCustomerGrowthRate),
    safeQuery('customerLifetimeValue', getCustomerLifetimeValue),
    safeQuery('revenueByCustomerAge', getRevenueByCustomerAge),
    safeQuery('recurringRevenue', getRecurringRevenue),
    safeQuery('expenseTrends', getExpenseTrends),
    safeQuery('dealVelocity', getDealVelocity),
    safeQuery('customerProfitability', getCustomerProfitability)
  ]);

  // If financialSummary is missing, provide a fallback to avoid UI errors
  if (!dashboardData.financialSummary) {
    dashboardData.financialSummary = {
      monthlyRevenue: 0,
      monthlyExpenses: 0,
      netProfit: 0,
      cashBalance: 0,
      revenueChange: 0,
      expensesChange: 0,
      netProfitChange: 0
    };
  }

  // Return all available dashboard data, even if some parts failed
  return NextResponse.json({
    status: hasErrors ? 'partial' : 'success',
    data: dashboardData,
    errors: hasErrors ? errors : undefined
  });
} 