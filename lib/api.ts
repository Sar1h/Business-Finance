export async function fetchDashboardData() {
  try {
    const response = await fetch('/api/dashboard');
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

export async function getMonthlyData() {
  const data = await fetchDashboardData();
  return data.monthlyData;
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