import { NextResponse } from 'next/server';
import {
  getFinancialSummary,
  getMonthlyRevenueExpenses,
  getCustomerSegments,
  getSalesFunnel,
  getCashflowTimeline,
  getKpiMetrics,
  getRecentTransactions
} from '@/lib/db';

export async function GET() {
  try {
    // Fetch all dashboard data in parallel
    const [
      financialSummary,
      monthlyData,
      customerSegments,
      salesFunnel,
      cashflowTimeline,
      kpiMetrics,
      recentTransactions
    ] = await Promise.all([
      getFinancialSummary(),
      getMonthlyRevenueExpenses(),
      getCustomerSegments(),
      getSalesFunnel(),
      getCashflowTimeline(),
      getKpiMetrics(),
      getRecentTransactions(5) // Get last 5 transactions
    ]);

    // Return all dashboard data
    return NextResponse.json({
      status: 'success',
      data: {
        financialSummary,
        monthlyData,
        customerSegments,
        salesFunnel,
        cashflowTimeline,
        kpiMetrics,
        recentTransactions
      }
    });
  } catch (error) {
    console.error('Dashboard data fetch error:', error);
    return NextResponse.json({
      status: 'error',
      message: 'Failed to fetch dashboard data'
    }, { status: 500 });
  }
} 