"use client"

import { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'
import { getCashflowTimeline } from '@/lib/api'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function CashflowTimelineChart() {
  const [cashflowData, setCashflowData] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getCashflowTimeline();
        setCashflowData(data);
      } catch (error) {
        console.error('Error fetching cashflow data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const options: ApexOptions = {
    chart: {
      type: 'area',
      fontFamily: 'inherit',
      toolbar: {
        show: false,
      },
      zoom: {
        enabled: false,
      },
    },
    dataLabels: {
      enabled: false,
    },
    stroke: {
      curve: 'smooth',
      width: 3,
    },
    grid: {
      borderColor: '#f1f5f9',
      strokeDashArray: 4,
      padding: {
        top: 0,
        right: 0,
        bottom: 0,
        left: 10,
      },
    },
    xaxis: {
      categories: cashflowData.map(item => {
        const date = new Date(item.projection_date);
        return date.toLocaleString('default', { month: 'short' });
      }),
      labels: {
        style: {
          colors: '#71717a',
        },
      },
      axisBorder: {
        show: false,
      },
      axisTicks: {
        show: false,
      },
    },
    yaxis: {
      labels: {
        style: {
          colors: '#71717a',
        },
        formatter: function(val: number) {
          return '₹' + (val / 1000).toFixed(0) + 'k'
        },
      },
    },
    tooltip: {
      y: {
        formatter: function(val: number) {
          return '₹' + (val / 1000).toFixed(2) + 'k'
        },
      },
    },
    fill: {
      type: 'gradient',
      gradient: {
        shadeIntensity: 1,
        opacityFrom: 0.7,
        opacityTo: 0.2,
        stops: [0, 90, 100],
      },
    },
    colors: ['#f97316', '#94a3b8'],
    legend: {
      position: 'top',
      horizontalAlign: 'right',
      markers: {
        size: 8,
        strokeWidth: 0,
      },
    },
  }

  const series = [
    {
      name: 'Cash In',
      data: cashflowData.map(item => item.actual_inflow || item.projected_inflow),
    },
    {
      name: 'Cash Out',
      data: cashflowData.map(item => item.actual_outflow || item.projected_outflow),
    },
  ]

  if (isLoading) {
    return <div className="h-[350px] flex items-center justify-center">Loading...</div>;
  }

  return (
    <div className="mt-4">
      {typeof window !== 'undefined' && (
        <ReactApexChart 
          options={options}
          series={series}
          type="area"
          height={350}
        />
      )}
    </div>
  )
} 