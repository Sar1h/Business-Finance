import { NextResponse } from 'next/server';
import db from '@/lib/db';

/**
 * GET handler for /api/transactions
 * Retrieves transactions with optional filtering
 */
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '50');
    const offset = parseInt(searchParams.get('offset') || '0');
    const type = searchParams.get('type'); // 'revenue' or 'expense'
    const startDate = searchParams.get('startDate');
    const endDate = searchParams.get('endDate');
    const category = searchParams.get('category');
    const customer = searchParams.get('customer');

    // Build the query conditions
    let conditions = [];
    let params = [];

    if (type) {
      conditions.push('t.type = ?');
      params.push(type);
    }

    if (startDate) {
      conditions.push('t.transaction_date >= ?');
      params.push(startDate);
    }

    if (endDate) {
      conditions.push('t.transaction_date <= ?');
      params.push(endDate);
    }

    if (category) {
      conditions.push(`
        (t.type = 'revenue' AND (SELECT category_name FROM revenue_categories WHERE id = t.category_id) LIKE ?) OR
        (t.type = 'expense' AND (SELECT category_name FROM expense_categories WHERE id = t.category_id) LIKE ?)
      `);
      params.push(`%${category}%`, `%${category}%`);
    }

    if (customer) {
      conditions.push('(SELECT name FROM customers WHERE id = t.customer_id) LIKE ?');
      params.push(`%${customer}%`);
    }

    // Assemble the SQL query
    let sql = `
      SELECT 
        t.id,
        t.transaction_date,
        t.description,
        t.amount,
        t.type,
        t.category_id,
        t.customer_id,
        t.recurring,
        t.recurring_frequency,
        CASE 
          WHEN t.type = 'revenue' THEN (SELECT category_name FROM revenue_categories WHERE id = t.category_id)
          WHEN t.type = 'expense' THEN (SELECT category_name FROM expense_categories WHERE id = t.category_id)
          ELSE NULL
        END AS category_name,
        CASE 
          WHEN t.customer_id IS NOT NULL THEN (SELECT name FROM customers WHERE id = t.customer_id)
          ELSE NULL
        END AS customer_name
      FROM transactions t
    `;

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    sql += ' ORDER BY t.transaction_date DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    // Count total matching transactions for pagination
    let countSql = 'SELECT COUNT(*) AS total FROM transactions t';
    if (conditions.length > 0) {
      countSql += ' WHERE ' + conditions.join(' AND ');
    }

    const transactions = await db.query(sql, params);
    const [countResult] = await db.query(countSql, params.slice(0, -2)); // Remove limit and offset params

    return NextResponse.json({
      status: 'success',
      data: transactions,
      pagination: {
        total: countResult.total,
        limit,
        offset
      }
    });
  } catch (error) {
    console.error('Error fetching transactions:', error);
    return NextResponse.json(
      {
        status: 'error',
        message: 'Failed to fetch transactions',
        error: error.message
      },
      { status: 500 }
    );
  }
}

/**
 * POST handler for /api/transactions
 * Creates a new transaction
 */
export async function POST(request) {
  try {
    const data = await request.json();
    const { 
      transaction_date, 
      description, 
      amount, 
      type, 
      category_id, 
      customer_id, 
      recurring, 
      recurring_frequency 
    } = data;

    // Validate required fields
    if (!transaction_date || !amount || !type || !category_id) {
      return NextResponse.json(
        {
          status: 'error',
          message: 'Missing required fields: transaction_date, amount, type, and category_id are required'
        },
        { status: 400 }
      );
    }

    // Insert the new transaction
    const sql = `
      INSERT INTO transactions (
        transaction_date,
        description,
        amount,
        type,
        category_id,
        customer_id,
        recurring,
        recurring_frequency
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const params = [
      transaction_date,
      description || null,
      amount,
      type,
      category_id,
      customer_id || null,
      recurring || false,
      recurring_frequency || null
    ];

    const result = await db.query(sql, params);

    // Get the newly created transaction
    const [newTransaction] = await db.query(
      'SELECT * FROM transactions WHERE id = ?',
      [result.insertId]
    );

    return NextResponse.json({
      status: 'success',
      message: 'Transaction created successfully',
      data: newTransaction
    }, { status: 201 });
  } catch (error) {
    console.error('Error creating transaction:', error);
    return NextResponse.json(
      {
        status: 'error',
        message: 'Failed to create transaction',
        error: error.message
      },
      { status: 500 }
    );
  }
}

/**
 * PATCH handler for /api/transactions/:id
 * Updates an existing transaction
 */
export async function PATCH(request, { params }) {
  try {
    const id = params.id;
    const data = await request.json();
    
    // Check if transaction exists
    const [existingTransaction] = await db.query(
      'SELECT * FROM transactions WHERE id = ?',
      [id]
    );

    if (!existingTransaction) {
      return NextResponse.json(
        {
          status: 'error',
          message: `Transaction with ID ${id} not found`
        },
        { status: 404 }
      );
    }

    // Build update query parts
    const updateFields = [];
    const updateParams = [];

    // Only update fields that are provided
    if (data.transaction_date !== undefined) {
      updateFields.push('transaction_date = ?');
      updateParams.push(data.transaction_date);
    }
    
    if (data.description !== undefined) {
      updateFields.push('description = ?');
      updateParams.push(data.description);
    }
    
    if (data.amount !== undefined) {
      updateFields.push('amount = ?');
      updateParams.push(data.amount);
    }
    
    if (data.type !== undefined) {
      updateFields.push('type = ?');
      updateParams.push(data.type);
    }
    
    if (data.category_id !== undefined) {
      updateFields.push('category_id = ?');
      updateParams.push(data.category_id);
    }
    
    if (data.customer_id !== undefined) {
      updateFields.push('customer_id = ?');
      updateParams.push(data.customer_id);
    }
    
    if (data.recurring !== undefined) {
      updateFields.push('recurring = ?');
      updateParams.push(data.recurring);
    }
    
    if (data.recurring_frequency !== undefined) {
      updateFields.push('recurring_frequency = ?');
      updateParams.push(data.recurring_frequency);
    }

    // If no fields to update, return early
    if (updateFields.length === 0) {
      return NextResponse.json({
        status: 'success',
        message: 'No changes to update',
        data: existingTransaction
      });
    }

    // Add ID to params for WHERE clause
    updateParams.push(id);

    // Perform the update
    const sql = `
      UPDATE transactions
      SET ${updateFields.join(', ')}
      WHERE id = ?
    `;

    await db.query(sql, updateParams);

    // Get the updated transaction
    const [updatedTransaction] = await db.query(
      'SELECT * FROM transactions WHERE id = ?',
      [id]
    );

    return NextResponse.json({
      status: 'success',
      message: 'Transaction updated successfully',
      data: updatedTransaction
    });
  } catch (error) {
    console.error('Error updating transaction:', error);
    return NextResponse.json(
      {
        status: 'error',
        message: 'Failed to update transaction',
        error: error.message
      },
      { status: 500 }
    );
  }
}

/**
 * DELETE handler for /api/transactions/:id
 * Deletes a transaction
 */
export async function DELETE(request, { params }) {
  try {
    const id = params.id;

    // Check if transaction exists
    const [existingTransaction] = await db.query(
      'SELECT * FROM transactions WHERE id = ?',
      [id]
    );

    if (!existingTransaction) {
      return NextResponse.json(
        {
          status: 'error',
          message: `Transaction with ID ${id} not found`
        },
        { status: 404 }
      );
    }

    // Delete the transaction
    await db.query('DELETE FROM transactions WHERE id = ?', [id]);

    return NextResponse.json({
      status: 'success',
      message: 'Transaction deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting transaction:', error);
    return NextResponse.json(
      {
        status: 'error',
        message: 'Failed to delete transaction',
        error: error.message
      },
      { status: 500 }
    );
  }
} 