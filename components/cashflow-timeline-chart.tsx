"use client"

import React from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function CashflowTimelineChart() {
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
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
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
        formatter: function(val) {
          return '₹' + val.toFixed(0) + 'k'
        },
      },
    },
    tooltip: {
      y: {
        formatter: function(val) {
          return '₹' + val.toFixed(2) + 'k'
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
      data: [35, 41, 36, 26, 45, 48, 52, 53, 41, 55, 58, 62],
    },
    {
      name: 'Cash Out',
      data: [25, 31, 33, 30, 38, 42, 37, 36, 33, 40, 45, 50],
    },
  ]

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