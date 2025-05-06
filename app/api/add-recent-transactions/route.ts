import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // Get all customers to distribute transactions among them
    const customers = await query<{ id: number; name: string }>(
      'SELECT id, name FROM customers LIMIT 10'
    );
    
    if (customers.length === 0) {
      return NextResponse.json({
        success: false,
        message: 'No customers found to add transactions for'
      });
    }

    // Get all categories 
    const revenueCategories = await query<{ id: number; category_name: string }>(
      'SELECT id, category_name FROM categories WHERE type = "revenue" LIMIT 5'
    );
    
    const expenseCategories = await query<{ id: number; category_name: string }>(
      'SELECT id, category_name FROM categories WHERE type = "expense" LIMIT 5'
    );
    
    if (revenueCategories.length === 0 || expenseCategories.length === 0) {
      return NextResponse.json({
        success: false,
        message: 'No categories found'
      });
    }
    
    // Current date info
    const currentDate = new Date();
    const currentMonth = currentDate.getMonth();
    const currentYear = currentDate.getFullYear();
    
    // Previous month
    const prevMonth = currentMonth === 0 ? 11 : currentMonth - 1;
    const prevYear = currentMonth === 0 ? currentYear - 1 : currentYear;
    
    // Create transactions for current and previous month
    const transactions = [];
    
    // For each customer, add some transactions
    for (const customer of customers) {
      // Current month transactions
      // Revenue transactions
      for (let i = 0; i < 3; i++) {
        const revCat = revenueCategories[Math.floor(Math.random() * revenueCategories.length)];
        const amount = 1000 + Math.floor(Math.random() * 9000);
        const day = Math.floor(Math.random() * 28) + 1;
        
        const txDate = new Date(currentYear, currentMonth, day);
        
        transactions.push({
          customer_id: customer.id,
          category_id: revCat.id,
          amount,
          transaction_date: txDate.toISOString().split('T')[0],
          description: `${revCat.category_name} revenue from ${customer.name}`,
          type: 'revenue',
          recurring: Math.random() > 0.5 ? 1 : 0,
          recurring_frequency: Math.random() > 0.5 ? 'monthly' : null
        });
      }
      
      // Expense transactions
      for (let i = 0; i < 2; i++) {
        const expCat = expenseCategories[Math.floor(Math.random() * expenseCategories.length)];
        const amount = 500 + Math.floor(Math.random() * 3000);
        const day = Math.floor(Math.random() * 28) + 1;
        
        const txDate = new Date(currentYear, currentMonth, day);
        
        transactions.push({
          customer_id: customer.id,
          category_id: expCat.id,
          amount,
          transaction_date: txDate.toISOString().split('T')[0],
          description: `${expCat.category_name} expense for ${customer.name}`,
          type: 'expense',
          recurring: Math.random() > 0.7 ? 1 : 0,
          recurring_frequency: Math.random() > 0.7 ? 'monthly' : null
        });
      }
      
      // Previous month transactions
      // Revenue transactions for previous month
      for (let i = 0; i < 2; i++) {
        const revCat = revenueCategories[Math.floor(Math.random() * revenueCategories.length)];
        const amount = 1000 + Math.floor(Math.random() * 9000);
        const day = Math.floor(Math.random() * 28) + 1;
        
        const txDate = new Date(prevYear, prevMonth, day);
        
        transactions.push({
          customer_id: customer.id,
          category_id: revCat.id,
          amount,
          transaction_date: txDate.toISOString().split('T')[0],
          description: `${revCat.category_name} revenue from ${customer.name}`,
          type: 'revenue',
          recurring: Math.random() > 0.5 ? 1 : 0,
          recurring_frequency: Math.random() > 0.5 ? 'monthly' : null
        });
      }
      
      // Expense transactions for previous month
      for (let i = 0; i < 2; i++) {
        const expCat = expenseCategories[Math.floor(Math.random() * expenseCategories.length)];
        const amount = 500 + Math.floor(Math.random() * 3000);
        const day = Math.floor(Math.random() * 28) + 1;
        
        const txDate = new Date(prevYear, prevMonth, day);
        
        transactions.push({
          customer_id: customer.id,
          category_id: expCat.id,
          amount,
          transaction_date: txDate.toISOString().split('T')[0],
          description: `${expCat.category_name} expense for ${customer.name}`,
          type: 'expense',
          recurring: Math.random() > 0.7 ? 1 : 0,
          recurring_frequency: Math.random() > 0.7 ? 'monthly' : null
        });
      }
    }
    
    // Insert all transactions
    let insertedCount = 0;
    
    // First check if the transactions table requires tax_relevant field
    const tableInfo = await query(
      `SHOW COLUMNS FROM transactions LIKE 'tax_relevant'`
    );
    
    const hasTaxRelevant = tableInfo.length > 0;
    
    for (const tx of transactions) {
      // Construct query dynamically based on the table structure
      let insertQuery;
      let queryParams;
      
      if (hasTaxRelevant) {
        insertQuery = `
          INSERT INTO transactions (
            customer_id, category_id, amount, transaction_date, description, 
            type, recurring, recurring_frequency, tax_relevant
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        queryParams = [
          tx.customer_id,
          tx.category_id,
          tx.amount,
          tx.transaction_date,
          tx.description,
          tx.type,
          tx.recurring,
          tx.recurring_frequency,
          false // Default tax_relevant value
        ];
      } else {
        insertQuery = `
          INSERT INTO transactions (
            customer_id, category_id, amount, transaction_date, description, 
            type, recurring, recurring_frequency
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `;
        queryParams = [
          tx.customer_id,
          tx.category_id,
          tx.amount,
          tx.transaction_date,
          tx.description,
          tx.type,
          tx.recurring,
          tx.recurring_frequency
        ];
      }
      
      await query(insertQuery, queryParams);
      insertedCount++;
    }
    
    return NextResponse.json({
      success: true,
      message: `Added ${insertedCount} recent transactions`,
      transactionCount: insertedCount,
      monthsAdded: [`${currentYear}-${currentMonth+1}`, `${prevYear}-${prevMonth+1}`]
    });
  } catch (error) {
    console.error('Error adding recent transactions:', error);
    return NextResponse.json(
      { 
        success: false, 
        message: 'Failed to add recent transactions', 
        error: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    );
  }
} 