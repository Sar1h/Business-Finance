"use client"

import { Chart } from "@/components/chart"

export default function ChartSection() {
  const formatValue = (val: number) => {
    return "$ " + val + " thousands";
  };

  return (
    <Chart
      type="bar"
      options={{
        chart: {
          toolbar: {
            show: false,
          },
        },
        plotOptions: {
          bar: {
            horizontal: false,
            columnWidth: "55%",
          },
        },
        dataLabels: {
          enabled: false,
        },
        stroke: {
          show: true,
          width: 2,
          colors: ["transparent"],
        },
        xaxis: {
          categories: ["Nov", "Dec", "Jan", "Feb", "Mar", "Apr"],
        },
        fill: {
          opacity: 1,
        },
        tooltip: {
          y: {
            formatter: formatValue,
          },
        },
      }}
      series={[
        {
          name: "Revenue",
          data: [28.4, 29.1, 30.6, 31.2, 31.8, 32.5],
        },
        {
          name: "Expenses",
          data: [16.8, 17.2, 17.5, 17.9, 18.1, 18.4],
        },
      ]}
      height={350}
      className="mt-4"
    />
  );
} 