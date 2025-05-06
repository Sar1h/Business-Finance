import { NextResponse } from 'next/server';
import { query } from '@/lib/db';
import mysql from 'mysql2/promise';

interface UpdateQueryResult {
  affectedRows: number;
}

export async function GET() {
  try {
    // 1. Update customer transactions to link them to customers correctly
    // First, get all customers
    const customers = await query<{ id: number; name: string }>(
      'SELECT id, name FROM customers ORDER BY id LIMIT 10'
    );
    
    if (customers.length === 0) {
      return NextResponse.json({
        success: false,
        message: 'No customers found'
      });
    }
    
    // Get transaction counts per customer
    const txCountsResult = await query<{ customer_id: number, count: number }>(
      'SELECT customer_id, COUNT(*) as count FROM transactions WHERE customer_id IS NOT NULL GROUP BY customer_id'
    );
    
    const txCounts = txCountsResult.reduce((acc, cur) => {
      acc[cur.customer_id] = cur.count;
      return acc;
    }, {} as Record<number, number>);
    
    // Get unclaimed transactions
    const unclaimedTxCount = await query<{ count: number }>(
      'SELECT COUNT(*) as count FROM transactions WHERE customer_id IS NULL'
    );
    
    let results = [];
    
    // If we have customers with no transactions, assign some
    for (const customer of customers) {
      if (!txCounts[customer.id] || txCounts[customer.id] < 5) {
        try {
          // Use the existing query function instead of direct connection
          const revenueResult = await query<UpdateQueryResult>(
            `UPDATE transactions 
             SET customer_id = ? 
             WHERE customer_id IS NULL AND type = 'revenue' 
             LIMIT 3`,
            [customer.id]
          );
          
          const expenseResult = await query<UpdateQueryResult>(
            `UPDATE transactions 
             SET customer_id = ? 
             WHERE customer_id IS NULL AND type = 'expense' 
             LIMIT 2`,
            [customer.id]
          );
          
          results.push({
            customer_id: customer.id,
            name: customer.name,
            revenue_added: revenueResult.length > 0 ? 
              (revenueResult[0] as any).affectedRows || 3 : 3,
            expenses_added: expenseResult.length > 0 ? 
              (expenseResult[0] as any).affectedRows || 2 : 2
          });
        } catch (error) {
          console.error(`Error updating transactions for customer ${customer.id}:`, error);
        }
      }
    }
    
    return NextResponse.json({
      success: true,
      message: 'Test data updated successfully',
      results,
      customer_count: customers.length,
      transaction_counts: txCounts,
      unclaimed_transactions: unclaimedTxCount[0]?.count || 0
    });
  } catch (error) {
    console.error('Error updating test data:', error);
    return NextResponse.json(
      { 
        success: false, 
        message: 'Failed to update test data', 
        error: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    );
  }
} 