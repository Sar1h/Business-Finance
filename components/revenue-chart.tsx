"use client"

import React from 'react'
import dynamic from 'next/dynamic'

// Dynamically import ApexCharts to prevent SSR issues
const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function RevenueChart() {
  const options = {
    chart: {
      toolbar: {
        show: false,
      },
      type: 'bar',
    },
    plotOptions: {
      bar: {
        horizontal: false,
        columnWidth: '55%',
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
    },
    yaxis: {
      title: {
        text: '$ (thousands)',
      },
    },
    fill: {
      opacity: 1,
    },
    tooltip: {
      y: {
        formatter: function(val: number) {
          return '$ ' + val + ' thousands'
        },
      },
    },
    colors: ['#2563eb', '#d1d5db'],
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