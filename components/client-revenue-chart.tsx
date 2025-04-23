"use client"

import React from 'react'
import dynamic from 'next/dynamic'

// Import ApexCharts types
import { ApexOptions } from 'apexcharts'

// Dynamically import ApexCharts to prevent SSR issues
const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function ClientRevenueChart() {
  const formatValue = (val: number) => {
    return "₹ " + val + " thousands";
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
      categories: ['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr'],
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
        },
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
  }

  const series = [
    {
      name: 'Revenue',
      data: [28.4, 29.1, 30.6, 31.2, 31.8, 32.5],
    },
    {
      name: 'Expenses',
      data: [16.8, 17.2, 17.5, 17.9, 18.1, 18.4],
    },
  ]

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