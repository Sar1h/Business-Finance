import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // Try to query the customers table to test DB connection
    const customers = await query<{ id: number; name: string }>(
      'SELECT id, name FROM customers LIMIT 5'
    );
    
    return NextResponse.json({
      success: true,
      message: 'Database connection successful',
      data: customers
    });
  } catch (error) {
    console.error('Database connection test failed:', error);
    return NextResponse.json(
      { 
        success: false, 
        message: 'Database connection failed', 
        error: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    );
  }
} 