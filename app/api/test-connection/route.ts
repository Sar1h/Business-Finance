import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // Test query to verify connection
    const testResult = await query('SELECT 1 as test');
    return NextResponse.json({ 
      status: 'success', 
      message: 'Database connection successful',
      data: testResult 
    });
  } catch (error) {
    console.error('API route database test error:', error);
    return NextResponse.json({ 
      status: 'error', 
      message: 'Database connection failed' 
    }, { status: 500 });
  }
} 