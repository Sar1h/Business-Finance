"use client"

import React from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function SalesFunnelChart() {
  const options: ApexOptions = {
    chart: {
      type: 'bar',
      height: 350,
      stacked: true,
      fontFamily: 'inherit',
    },
    plotOptions: {
      bar: {
        horizontal: true,
        barHeight: '80%',
        borderRadius: 6,
      },
    },
    dataLabels: {
      enabled: true,
      formatter: function(val) {
        return val + '%'
      },
      style: {
        fontSize: '12px',
        colors: ['#fff'],
        fontWeight: 'normal',
      },
    },
    stroke: {
      width: 0,
    },
    grid: {
      borderColor: '#f1f5f9',
      strokeDashArray: 4,
    },
    xaxis: {
      categories: ['Awareness', 'Interest', 'Consideration', 'Intent', 'Purchase'],
      labels: {
        style: {
          colors: '#71717a',
        },
      },
    },
    yaxis: {
      labels: {
        style: {
          colors: '#71717a',
        },
      },
    },
    tooltip: {
      y: {
        formatter: function(val) {
          return val + "%"
        }
      }
    },
    fill: {
      opacity: 1,
      type: 'gradient',
      gradient: {
        shade: 'light',
        type: "horizontal",
        shadeIntensity: 0.25,
        gradientToColors: undefined,
        inverseColors: true,
        opacityFrom: 0.85,
        opacityTo: 1,
        stops: [50, 0, 100],
      },
    },
    colors: ['#fb923c', '#fdba74', '#fed7aa', '#ffedd5'],
    legend: {
      position: 'top',
      horizontalAlign: 'right',
      markers: {
        size: 12,
        strokeWidth: 0,
      },
    },
  }

  const series = [
    {
      name: 'Conversion Rate',
      data: [100, 65, 40, 24, 12],
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