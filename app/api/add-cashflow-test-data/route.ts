import { NextResponse } from 'next/server';
import { query } from '@/lib/db';

export async function GET() {
  try {
    // First, check if we already have cashflow data
    const existingData = await query<{count: number}>('SELECT COUNT(*) as count FROM cashflow');
    const existingCount = existingData[0]?.count || 0;
    
    if (existingCount > 0) {
      return NextResponse.json({
        success: true,
        message: `Cashflow data already exists (${existingCount} records)`,
        added: 0
      });
    }
    
    // Start date 6 months ago
    const startDate = new Date();
    startDate.setMonth(startDate.getMonth() - 6);
    startDate.setDate(1); // First day of month
    
    const cashflowData = [];
    
    // Generate 12 months of cashflow data (6 past + 6 future)
    for (let i = 0; i < 12; i++) {
      const currentDate = new Date(startDate);
      currentDate.setMonth(startDate.getMonth() + i);
      
      // Generate some realistic looking data
      const baseInflow = 10000 + Math.floor(Math.random() * 5000);
      const baseOutflow = 8000 + Math.floor(Math.random() * 4000);
      
      // Past months have actual data, future months only have projections
      const isPastMonth = i < 6;
      
      cashflowData.push({
        period_date: currentDate.toISOString().split('T')[0],
        projected_inflow: baseInflow,
        projected_outflow: baseOutflow,
        actual_inflow: isPastMonth ? baseInflow * (0.8 + Math.random() * 0.4) : null,
        actual_outflow: isPastMonth ? baseOutflow * (0.8 + Math.random() * 0.4) : null,
        notes: `Test data for ${currentDate.toLocaleString('default', { month: 'long', year: 'numeric' })}`
      });
    }
    
    // Insert the data
    let insertedCount = 0;
    for (const data of cashflowData) {
      await query(
        `INSERT INTO cashflow (
          period_date, projected_inflow, projected_outflow, actual_inflow, actual_outflow, notes
        ) VALUES (?, ?, ?, ?, ?, ?)`,
        [
          data.period_date,
          data.projected_inflow,
          data.projected_outflow,
          data.actual_inflow,
          data.actual_outflow,
          data.notes
        ]
      );
      insertedCount++;
    }
    
    return NextResponse.json({
      success: true,
      message: `Added ${insertedCount} cashflow records`,
      data: cashflowData
    });
  } catch (error) {
    console.error('Error adding test cashflow data:', error);
    return NextResponse.json(
      { 
        success: false, 
        message: 'Failed to add test cashflow data', 
        error: error instanceof Error ? error.message : String(error)
      },
      { status: 500 }
    );
  }
} 