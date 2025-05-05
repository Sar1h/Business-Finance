"use client"

import React, { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { getSalesFunnel } from '@/lib/api'
import { SalesFunnelData } from '@/lib/types'

// Import ApexCharts types
import { ApexOptions } from 'apexcharts'

// Dynamically import ApexCharts to prevent SSR issues
const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function SalesFunnelChart() {
  const [funnelData, setFunnelData] = useState<SalesFunnelData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getSalesFunnel();
        setFunnelData(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Error fetching sales funnel data:', error);
        setError('Failed to load sales funnel data');
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const options: ApexOptions = {
    chart: {
      type: 'bar',
      height: 350,
      stacked: true,
      toolbar: {
        show: false
      }
    },
    plotOptions: {
      bar: {
        horizontal: true,
        dataLabels: {
          position: 'top',
        },
      }
    },
    dataLabels: {
      enabled: true,
      offsetX: -6,
      style: {
        fontSize: '12px',
        colors: ['#fff']
      },
      formatter: function(val) {
        return (typeof val === 'number' ? val.toFixed(1) : val) + '%';
      }
    },
    stroke: {
      width: 1,
      colors: ['#fff']
    },
    xaxis: {
      categories: funnelData.map(item => item.stage_name),
      labels: {
        style: {
          colors: '#71717a',
        }
      }
    },
    yaxis: {
      labels: {
        style: {
          colors: '#71717a',
        }
      }
    },
    tooltip: {
      theme: 'light',
      y: {
        formatter: function (val) {
          return (typeof val === 'number' ? val.toFixed(1) : val) + '%';
        }
      }
    },
    fill: {
      opacity: 1
    },
    legend: {
      position: 'top',
      horizontalAlign: 'left',
      offsetX: 40,
      labels: {
        colors: '#71717a',
      }
    },
    grid: {
      borderColor: '#f1f5f9',
      strokeDashArray: 4,
    },
    colors: ['#f97316', '#fbd38d'],
  };

  const series = [{
    name: 'Conversion Rate',
    data: funnelData.map(item => typeof item?.conversion_rate === 'number' ? parseFloat(item.conversion_rate.toFixed(1)) : 0)
  }];

  if (isLoading) {
    return <div className="h-[350px] flex items-center justify-center">Loading...</div>;
  }

  if (error) {
    return <div className="h-[350px] flex items-center justify-center text-red-500">{error}</div>;
  }
  
  if (funnelData.length === 0) {
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