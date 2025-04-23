"use client"

import React from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

type KpiChartProps = {
  title: string
  value: number
  color: string
  suffix?: string
}

const KpiChart = ({ title, value, color, suffix = '%' }: KpiChartProps) => {
  const options: ApexOptions = {
    chart: {
      height: 150,
      type: 'radialBar',
      fontFamily: 'inherit',
      toolbar: {
        show: false,
      },
    },
    plotOptions: {
      radialBar: {
        startAngle: -135,
        endAngle: 135,
        hollow: {
          margin: 0,
          size: '70%',
        },
        track: {
          background: '#e2e8f0',
          strokeWidth: '97%',
          margin: 5,
          dropShadow: {
            enabled: false,
          }
        },
        dataLabels: {
          name: {
            show: false,
          },
          value: {
            fontSize: '22px',
            fontWeight: 600,
            color: '#334155',
            offsetY: 10,
            formatter: function(val) {
              return val + suffix
            }
          }
        }
      }
    },
    fill: {
      type: 'gradient',
      gradient: {
        shade: 'dark',
        type: 'horizontal',
        shadeIntensity: 0.5,
        gradientToColors: [color],
        inverseColors: true,
        opacityFrom: 1,
        opacityTo: 1,
        stops: [0, 100]
      }
    },
    stroke: {
      dashArray: 4
    },
    colors: [color],
  }

  const series = [value]

  return (
    <div className="flex flex-col items-center">
      {typeof window !== 'undefined' && (
        <ReactApexChart 
          options={options}
          series={series}
          type="radialBar"
          height={180}
          width={160}
        />
      )}
      <span className="mt-2 text-sm font-medium text-gray-600">{title}</span>
    </div>
  )
}

export default function KpiRadialCharts() {
  return (
    <div className="grid grid-cols-2 gap-6 sm:grid-cols-4">
      <KpiChart title="Sales Target" value={76} color="#f97316" />
      <KpiChart title="Customer Retention" value={84} color="#fb923c" />
      <KpiChart title="Profit Margin" value={42} color="#fdba74" />
      <KpiChart title="ROI" value={68} color="#ea580c" suffix="%" />
    </div>
  )
} 