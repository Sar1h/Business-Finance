"use client"

import React, { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { getCustomerSegments } from '@/lib/api'
import { CustomerSegment } from '@/lib/types'

// Import ApexCharts types
import { ApexOptions } from 'apexcharts'

// Dynamically import ApexCharts to prevent SSR issues
const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function CustomerSegmentsChart() {
  const [segmentsData, setSegmentsData] = useState<CustomerSegment[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getCustomerSegments();
        setSegmentsData(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Error fetching customer segments data:', error);
        setError('Failed to load customer segments data');
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
      type: 'pie',
      fontFamily: 'inherit',
      toolbar: {
        show: false,
      },
    },
    labels: segmentsData.map(item => {
      return `${item.business_size} (${item.count})`;
    }),
    dataLabels: {
      enabled: true,
      formatter: function(val: string | number): string {
        return typeof val === 'number' ? val.toFixed(1) + '%' : val;
      },
    },
    tooltip: {
      y: {
        formatter: function(val) {
          return segmentsData[val] ? formatValue(segmentsData[val].total_value) : '';
        }
      }
    },
    legend: {
      position: 'bottom',
      offsetY: 0,
      labels: {
        colors: '#71717a',
      }
    },
    colors: ['#f97316', '#fb923c', '#fdba74', '#fed7aa'],
    responsive: [{
      breakpoint: 480,
      options: {
        chart: {
          width: 300
        },
        legend: {
          position: 'bottom'
        }
      }
    }],
    plotOptions: {
      pie: {
        donut: {
          size: '50%',
        }
      }
    }
  };

  const series = segmentsData.map(item => item?.count || 0);

  if (isLoading) {
    return <div className="h-[350px] flex items-center justify-center">Loading...</div>;
  }

  if (error) {
    return <div className="h-[350px] flex items-center justify-center text-red-500">{error}</div>;
  }
  
  if (segmentsData.length === 0) {
    return <div className="h-[350px] flex items-center justify-center">No data available</div>;
  }

  return (
    <div className="mt-4">
      {typeof window !== 'undefined' && (
        <ReactApexChart 
          options={options}
          series={series}
          type="pie"
          height={350}
        />
      )}
    </div>
  )
} 