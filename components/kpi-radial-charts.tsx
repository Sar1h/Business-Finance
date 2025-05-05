"use client"

import React, { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { getKpiMetrics } from '@/lib/api'
import { KpiMetric } from '@/lib/types'

// Import ApexCharts types
import { ApexOptions } from 'apexcharts'

// Dynamically import ApexCharts to prevent SSR issues
const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function KpiRadialCharts() {
  const [kpiMetrics, setKpiMetrics] = useState<KpiMetric[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getKpiMetrics();
        setKpiMetrics(Array.isArray(data) ? data : []);
      } catch (error) {
        console.error('Error fetching KPI metrics:', error);
        setError('Failed to load KPI metrics');
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const getFormatter = (metric: KpiMetric) => {
    switch (metric.metric_type) {
      case 'percentage':
        return (val: number) => `${val.toFixed(1)}%`;
      case 'currency':
        return (val: number) => `₹${val.toLocaleString()}`;
      case 'months':
        return (val: number) => `${val.toFixed(1)} mo`;
      default:
        return (val: number) => val.toString();
    }
  };

  const getColor = (metric: KpiMetric) => {
    const progress = (metric.metric_value / metric.target_value) * 100;
    if (progress >= 100) return '#22c55e'; // Green
    if (progress >= 70) return '#f97316';  // Orange
    return '#ef4444';                      // Red
  };

  const getOptions = (metric: KpiMetric): ApexOptions => {
    return {
      chart: {
        height: 200,
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
          },
          dataLabels: {
            name: {
              show: true,
              fontSize: '14px',
              fontWeight: 600,
              color: '#334155',
              offsetY: -10
            },
            value: {
              formatter: getFormatter(metric),
              fontSize: '20px',
              fontWeight: 700,
              color: '#334155',
              offsetY: 5
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
          gradientToColors: [getColor(metric)],
          inverseColors: true,
          opacityFrom: 1,
          opacityTo: 1,
          stops: [0, 100]
        }
      },
      stroke: {
        dashArray: 3
      },
      labels: [metric.metric_name],
      colors: [getColor(metric)]
    };
  };

  if (isLoading) {
    return <div className="h-[180px] flex items-center justify-center">Loading KPI metrics...</div>;
  }

  if (error) {
    return <div className="h-[180px] flex items-center justify-center text-red-500">{error}</div>;
  }
  
  if (kpiMetrics.length === 0) {
    return <div className="h-[180px] flex items-center justify-center">No KPI data available</div>;
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      {kpiMetrics.map((metric, index) => (
        <div key={index}>
          {typeof window !== 'undefined' && (
            <ReactApexChart
              options={getOptions(metric)}
              series={[Math.min(100, (metric.metric_value / metric.target_value) * 100)]}
              type="radialBar"
              height={180}
            />
          )}
          <div className="text-center text-xs text-gray-500 -mt-4">{metric.description}</div>
        </div>
      ))}
    </div>
  )
} 