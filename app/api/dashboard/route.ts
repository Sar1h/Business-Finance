import { NextRequest, NextResponse } from 'next/server';
import {
  getFinancialSummary,
  getMonthlyRevenueExpenses,
  getCustomerSegments,
  getSalesFunnel,
  getCashflowTimeline,
  getKpiMetrics,
  getRecentTransactions,
  getCustomerFinancialSummary,
  getCustomerMonthlyData,
  getCustomerTransactions
} from '@/lib/db';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const customerIdParam = searchParams.get('customerId');
    let customerId = null;
    
    // Process customer ID if provided
    if (customerIdParam) {
      customerId = parseInt(customerIdParam);
      if (isNaN(customerId)) {
        return NextResponse.json(
          { error: 'Invalid customer ID' },
          { status: 400 }
        );
      }
    }
    
    // Get the appropriate data based on whether a customer ID is provided
    const financialSummary = customerId 
      ? await getCustomerFinancialSummary(customerId)
      : await getFinancialSummary();
    
    const monthlyData = customerId
      ? await getCustomerMonthlyData(customerId)
      : await getMonthlyRevenueExpenses();
    
    const transactions = customerId
      ? await getCustomerTransactions(customerId, 10)
      : await getRecentTransactions(10);
    
    // These remain the same regardless of whether a customer ID is provided
    const customerSegments = await getCustomerSegments();
    const salesFunnel = await getSalesFunnel();
    
    // Pass customerId to cashflow and KPI functions so they can filter data
    const cashflowTimeline = await getCashflowTimeline(customerId || undefined);
    const kpiMetrics = await getKpiMetrics(customerId || undefined);
    
    return NextResponse.json({
      data: {
        financialSummary,
        monthlyData,
        customerSegments,
        salesFunnel,
        cashflowTimeline,
        kpiMetrics,
        recentTransactions: transactions,
        customerId
      }
    });
  } catch (error) {
    console.error('Error getting dashboard data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch dashboard data' },
      { status: 500 }
    );
  }
} 