"use client"

import React, { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'
import { getKpiMetrics } from '@/lib/api'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

interface KpiChartProps {
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
  const [kpiData, setKpiData] = useState<any>({
    salesTarget: 0,
    customerRetention: 0,
    profitMargin: 0,
    roi: 0
  });
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getKpiMetrics();
        const metrics = data.reduce((acc: any, metric: any) => {
          acc[metric.metric_name.toLowerCase().replace(/\s+/g, '')] = parseFloat(metric.metric_value);
          return acc;
        }, {});
        
        setKpiData(metrics);
      } catch (error) {
        console.error('Error fetching KPI metrics:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  if (isLoading) {
    return <div className="h-[180px] w-full flex items-center justify-center">Loading KPIs...</div>;
  }

  return (
    <div className="grid grid-cols-2 gap-6 sm:grid-cols-4">
      <KpiChart title="Sales Target" value={kpiData.salestarget || 0} color="#f97316" />
      <KpiChart title="Customer Retention" value={kpiData.customerretention || 0} color="#fb923c" />
      <KpiChart title="Profit Margin" value={kpiData.profitmargin || 0} color="#fdba74" />
      <KpiChart title="ROI" value={kpiData.roi || 0} color="#ea580c" suffix="%" />
    </div>
  )
} 