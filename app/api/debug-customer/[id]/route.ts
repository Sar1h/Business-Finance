import { NextRequest, NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const customerId = parseInt(params.id);
    
    if (isNaN(customerId)) {
      return NextResponse.json(
        { error: 'Invalid customer ID' },
        { status: 400 }
      );
    }
    
    // Get raw customer transactions data
    const transactionsQuery = `
      SELECT 
        t.id, 
        t.transaction_date, 
        t.description, 
        t.amount, 
        t.type,
        c.category_name,
        t.recurring,
        t.recurring_frequency
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.customer_id = ?
      ORDER BY t.transaction_date DESC
    `;
    
    const transactions = await query(transactionsQuery, [customerId]);
    
    // Get customer monthly revenue data
    const revenueQuery = `
      SELECT 
        DATE_FORMAT(transaction_date, '%Y-%m') AS month,
        SUM(CASE WHEN type = 'revenue' THEN amount ELSE 0 END) AS revenue,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) AS expense
      FROM transactions
      WHERE customer_id = ?
      GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
      ORDER BY month
    `;
    
    const monthlyData = await query(revenueQuery, [customerId]);
    
    // Get customer details
    const customerQuery = `
      SELECT 
        c.*,
        cs.segment_name,
        cs.profitability_score,
        cs.growth_potential
      FROM customers c
      LEFT JOIN customer_segments cs ON c.segment_id = cs.id
      WHERE c.id = ?
    `;
    
    const [customerInfo] = await query(customerQuery, [customerId]);
    
    return NextResponse.json({
      success: true,
      data: {
        customerInfo,
        transactions,
        monthlyData,
        transactionCount: transactions.length,
        monthlyDataCount: monthlyData.length
      }
    });
  } catch (error) {
    console.error('Error debugging customer data:', error);
    return NextResponse.json(
      { 
        success: false, 
        message: 'Error retrieving customer data', 
        error: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    );
  }
} 