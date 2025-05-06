export async function fetchDashboardData() {
  try {
    const { customerId } = getSearchParams();
    const url = customerId 
      ? `/api/dashboard?customerId=${customerId}` 
      : '/api/dashboard';
    
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error('Failed to fetch dashboard data');
    }
    const data = await response.json();
    return data.data;
  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    throw error;
  }
}

/**
 * Fetch generic monthly data
 */
export async function getMonthlyData() {
  try {
    const response = await fetch('/api/dashboard/monthly-data');
    if (!response.ok) {
      throw new Error('Failed to fetch monthly data');
    }
    return await response.json();
  } catch (error) {
    console.error('Error in getMonthlyData:', error);
    throw error;
  }
}

/**
 * Fetch customer-specific monthly data
 */
export async function getCustomerMonthlyData(customerId: number) {
  try {
    const response = await fetch(`/api/dashboard/monthly-data?customerId=${customerId}`);
    if (!response.ok) {
      throw new Error('Failed to fetch customer monthly data');
    }
    return await response.json();
  } catch (error) {
    console.error('Error in getCustomerMonthlyData:', error);
    throw error;
  }
}

/**
 * Get URL search params
 */
export function getSearchParams() {
  if (typeof window === 'undefined') {
    return {};
  }
  
  const params = new URLSearchParams(window.location.search);
  const customerId = params.get('customerId');
  
  return {
    customerId: customerId ? parseInt(customerId) : null
  };
}

export async function getFinancialSummary() {
  const data = await fetchDashboardData();
  return data.financialSummary;
}

export async function getCustomerSegments() {
  const data = await fetchDashboardData();
  return data.customerSegments;
}

export async function getSalesFunnel() {
  const data = await fetchDashboardData();
  return data.salesFunnel;
}

export async function getCashflowTimeline() {
  const data = await fetchDashboardData();
  return data.cashflowTimeline;
}

export async function getKpiMetrics() {
  const data = await fetchDashboardData();
  return data.kpiMetrics;
}

export async function getRecentTransactions() {
  const data = await fetchDashboardData();
  return data.recentTransactions;
}

export async function getCustomerGrowth() {
  const data = await fetchDashboardData();
  return data.customerGrowth;
}

export async function getCustomerLifetimeValue() {
  const data = await fetchDashboardData();
  return data.customerLifetimeValue;
}

export async function getRevenueByCustomerAge() {
  const data = await fetchDashboardData();
  return data.revenueByCustomerAge;
}

export async function getRecurringRevenue() {
  const data = await fetchDashboardData();
  return data.recurringRevenue;
}

export async function getExpenseTrends() {
  const data = await fetchDashboardData();
  return data.expenseTrends;
}

export async function getDealVelocity() {
  const data = await fetchDashboardData();
  return data.dealVelocity;
}

export async function getCustomerProfitability() {
  const data = await fetchDashboardData();
  return data.customerProfitability;
} 