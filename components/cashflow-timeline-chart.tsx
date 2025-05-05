"use client"

import React, { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { getCashflowTimeline } from '@/lib/api'
import { CashflowData } from '@/lib/types'

// Import ApexCharts types
import { ApexOptions } from 'apexcharts'

// Dynamically import ApexCharts to prevent SSR issues
const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function CashflowTimelineChart() {
  const [cashflowData, setCashflowData] = useState<CashflowData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getCashflowTimeline();
        setCashflowData(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Error fetching cashflow data:', error);
        setError('Failed to load cashflow data');
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const formatValue = (val: number) => {
    return "₹ " + val.toLocaleString();
  };

  const options: ApexOptions = {
    chart: {
      height: 350,
      type: 'line',
      toolbar: {
        show: false
      }
    },
    colors: ['#f97316', '#94a3b8', '#22c55e', '#a1a1aa'],
    stroke: {
      width: [4, 3, 4, 2],
      curve: 'smooth',
      dashArray: [0, 0, 0, 4]
    },
    xaxis: {
      type: 'category',
      categories: cashflowData.map(item => {
        const date = new Date(item.projection_date);
        return date.toLocaleString('default', { month: 'short', year: '2-digit' });
      }),
      labels: {
        style: {
          colors: '#71717a',
        }
      }
    },
    yaxis: {
      title: {
        text: 'Amount (₹)',
        style: {
          color: '#71717a',
        }
      },
      labels: {
        style: {
          colors: '#71717a',
        },
        formatter: (value) => {
          return "₹" + value.toLocaleString(undefined, { maximumFractionDigits: 0 });
        }
      }
    },
    tooltip: {
      theme: 'light',
      y: {
        formatter: formatValue
      }
    },
    grid: {
      borderColor: '#f1f5f9',
      strokeDashArray: 4,
    },
    legend: {
      position: 'top',
      horizontalAlign: 'right',
      offsetX: -10,
      labels: {
        colors: '#71717a',
      }
    },
    markers: {
      size: 4,
      strokeWidth: 0,
      hover: {
        size: 6
      }
    }
  };

  const series = [
    {
      name: 'Projected Net',
      data: cashflowData.map(item => item?.projected_net || null)
    },
    {
      name: 'Projected Inflow',
      data: cashflowData.map(item => item?.projected_inflow || null)
    },
    {
      name: 'Actual Net',
      data: cashflowData.map(item => item?.actual_net || null)
    },
    {
      name: 'Actual Inflow',
      data: cashflowData.map(item => item?.actual_inflow || null)
    }
  ];

  if (isLoading) {
    return <div className="h-[350px] flex items-center justify-center">Loading...</div>;
  }

  if (error) {
    return <div className="h-[350px] flex items-center justify-center text-red-500">{error}</div>;
  }
  
  if (cashflowData.length === 0) {
    return <div className="h-[350px] flex items-center justify-center">No data available</div>;
  }

  return (
    <div className="mt-4">
      {typeof window !== 'undefined' && (
        <ReactApexChart 
          options={options}
          series={series}
          type="line"
          height={350}
        />
      )}
    </div>
  )
} 