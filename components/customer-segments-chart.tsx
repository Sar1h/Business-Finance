"use client"

import { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'
import { getCustomerSegments } from '@/lib/api'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function CustomerSegmentsChart() {
  const [segmentData, setSegmentData] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getCustomerSegments();
        setSegmentData(data);
      } catch (error) {
        console.error('Error fetching customer segments:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

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
              formatter: function(val: string) {
                return parseFloat(val).toFixed(1) + '%'
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
    labels: segmentData.map(segment => segment.business_size),
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
        formatter: function(val: number) {
          return val.toFixed(1) + '%'
        }
      }
    }
  }

  // Calculate percentages based on total value
  const calculatePercentages = () => {
    const total = segmentData.reduce((sum, segment) => sum + segment.total_value, 0);
    return segmentData.map(segment => parseFloat(((segment.total_value / total) * 100).toFixed(1)));
  };

  const series = calculatePercentages();

  if (isLoading) {
    return <div className="h-[300px] flex items-center justify-center">Loading...</div>;
  }

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