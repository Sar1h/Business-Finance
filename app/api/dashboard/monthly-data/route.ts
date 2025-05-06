import { NextRequest, NextResponse } from 'next/server';
import { getMonthlyRevenueExpenses, getCustomerMonthlyData } from '@/lib/db';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const customerIdParam = searchParams.get('customerId');
    
    let data;
    
    if (customerIdParam) {
      const customerId = parseInt(customerIdParam);
      if (isNaN(customerId)) {
        return NextResponse.json(
          { error: 'Invalid customer ID' },
          { status: 400 }
        );
      }
      
      data = await getCustomerMonthlyData(customerId);
    } else {
      data = await getMonthlyRevenueExpenses();
    }
    
    return NextResponse.json(data);
  } catch (error) {
    console.error('Error getting monthly data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch monthly data' },
      { status: 500 }
    );
  }
} 