"use client"

import { useEffect, useState } from 'react'
import dynamic from 'next/dynamic'
import { ApexOptions } from 'apexcharts'
import { getSalesFunnel } from '@/lib/api'

const ReactApexChart = dynamic(() => import('react-apexcharts'), { ssr: false })

export default function SalesFunnelChart() {
  const [funnelData, setFunnelData] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getSalesFunnel();
        setFunnelData(data);
      } catch (error) {
        console.error('Error fetching sales funnel data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, []);

  const options: ApexOptions = {
    chart: {
      type: 'bar',
      height: 350,
      toolbar: {
        show: false
      }
    },
    plotOptions: {
      bar: {
        borderRadius: 4,
        horizontal: true,
        barHeight: '80%',
        distributed: true
      }
    },
    dataLabels: {
      enabled: true,
      formatter: function (val: number) {
        return val.toFixed(1) + '%'
      },
      style: {
        fontSize: '12px',
        colors: ['#fff']
      }
    },
    xaxis: {
      categories: funnelData.map(item => item.stage_name),
      labels: {
        style: {
          colors: '#71717a',
        }
      }
    },
    yaxis: {
      labels: {
        style: {
          colors: '#71717a',
        }
      }
    },
    grid: {
      borderColor: '#f1f5f9',
      strokeDashArray: 4
    },
    colors: ['#f97316', '#fb923c', '#fdba74', '#fed7aa'],
    legend: {
      show: false
    },
    tooltip: {
      theme: 'light',
      y: {
        formatter: function(val) {
          return val.toFixed(1) + '%'
        }
      }
    }
  }

  const series = [{
    data: funnelData.map(item => item.conversion_rate)
  }]

  if (isLoading) {
    return <div className="h-[350px] flex items-center justify-center">Loading...</div>;
  }

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