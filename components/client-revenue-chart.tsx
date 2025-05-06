"use client"

import React, { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { getMonthlyData, getCustomerMonthlyData, getSearchParams } from '@/lib/api'
import { MonthlyData } from '@/lib/types'

// Import ApexCharts types
import { ApexOptions } from 'apexcharts'

// Dynamically import ApexCharts to prevent SSR issues
const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function ClientRevenueChart() {
  const [monthlyData, setMonthlyData] = useState<MonthlyData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [title, setTitle] = useState('Revenue & Expenses');

  useEffect(() => {
    const fetchData = async () => {
      try {
        const { customerId } = getSearchParams();
        let data;
        
        if (customerId) {
          data = await getCustomerMonthlyData(customerId);
          setTitle(`Revenue & Expenses for Customer #${customerId}`);
        } else {
          data = await getMonthlyData();
          setTitle('Revenue & Expenses');
        }
        
        setMonthlyData(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Error fetching monthly data:', error);
        setError('Failed to load revenue data');
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const formatValue = (val: number) => {
    return "₹ " + val.toLocaleString() + " thousands";
  };

  const options: ApexOptions = {
    chart: {
      toolbar: {
        show: false,
      },
      type: 'bar',
      fontFamily: 'inherit',
    },
    plotOptions: {
      bar: {
        horizontal: false,
        columnWidth: '55%',
        borderRadius: 4,
      },
    },
    dataLabels: {
      enabled: false,
    },
    stroke: {
      show: true,
      width: 2,
      colors: ['transparent'],
    },
    xaxis: {
      categories: monthlyData.map(item => {
        const [year, month] = item.month.split('-');
        const date = new Date(parseInt(year), parseInt(month) - 1);
        return date.toLocaleString('default', { month: 'short' });
      }),
      labels: {
        style: {
          colors: '#71717a',
        },
      },
    },
    yaxis: {
      title: {
        text: '₹ (thousands)',
        style: {
          color: '#71717a',
        }
      },
      labels: {
        style: {
          colors: '#71717a',
        },
      },
    },
    fill: {
      opacity: 1,
    },
    tooltip: {
      theme: 'light',
      y: {
        formatter: formatValue,
      },
    },
    grid: {
      borderColor: '#f1f5f9',
      strokeDashArray: 4,
    },
    colors: ['#f97316', '#e2e8f0'],
    title: {
      text: title,
      align: 'left',
      style: {
        fontSize: '16px',
        color: '#5a5a5a'
      }
    }
  }

  const series = [
    {
      name: 'Revenue',
      data: monthlyData.map(item => parseFloat(((item?.revenue || 0) / 1000).toFixed(1))),
    },
    {
      name: 'Expenses',
      data: monthlyData.map(item => parseFloat(((item?.expense || 0) / 1000).toFixed(1))),
    },
  ]

  if (isLoading) {
    return <div className="h-[350px] flex items-center justify-center">Loading...</div>;
  }
  
  if (error) {
    return <div className="h-[350px] flex items-center justify-center text-red-500">{error}</div>;
  }
  
  if (monthlyData.length === 0) {
    return <div className="h-[350px] flex items-center justify-center">No data available</div>;
  }

  return (
    <div className="mt-4">
      {typeof window !== 'undefined' && (
        <ReactApexChart 
          options={options}
          series={series}
          type="bar"
          height={350}
        />
      )}
    </div>
  )
} 