"use client"

import React from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function CustomerSegmentsChart() {
  const options: ApexOptions = {
    chart: {
      type: 'donut',
      fontFamily: 'inherit',
    },
    plotOptions: {
      pie: {
        donut: {
          size: '60%',
          labels: {
            show: true,
            name: {
              show: true,
              fontSize: '14px',
              fontWeight: 500,
              color: '#64748b',
            },
            value: {
              show: true,
              fontSize: '16px',
              fontWeight: 600,
              color: '#334155',
              formatter: function(val) {
                return val + '%'
              }
            },
            total: {
              show: true,
              label: 'Total',
              fontSize: '14px',
              fontWeight: 500,
              color: '#64748b',
              formatter: function() {
                return '100%'
              }
            }
          }
        }
      }
    },
    labels: ['Enterprise', 'SMB', 'Startups', 'Freelancers'],
    dataLabels: {
      enabled: false
    },
    stroke: {
      width: 1,
      colors: ['#fff']
    },
    fill: {
      opacity: 1,
      type: 'solid'
    },
    legend: {
      position: 'bottom',
      fontWeight: 500,
      markers: {
        size: 8,
        strokeWidth: 0,
      },
      itemMargin: {
        horizontal: 15
      }
    },
    colors: ['#f97316', '#fb923c', '#fdba74', '#fed7aa'],
    tooltip: {
      enabled: true,
      y: {
        formatter: function(val) {
          return val + '%'
        }
      }
    }
  }

  const series = [35, 30, 20, 15]

  return (
    <div className="mt-4">
      {typeof window !== 'undefined' && (
        <ReactApexChart 
          options={options}
          series={series}
          type="donut"
          height={300}
        />
      )}
    </div>
  )
} 