import ApexCharts from 'react-apexcharts';
import React, { useEffect, useState } from 'react';
import { statisticProbexptProcessed } from '../../../../API/statistic/statisticProbexptProcessed';

export default function Taste_Proc_Map({
  startDate,
  endDate,
  animalType,
  grade,
}) {
  const [chartData, setChartData] = useState({});
  const [prop, setProp] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await statisticProbexptProcessed(
          startDate,
          endDate,
          animalType,
          grade
        );

        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        const data = await response.json();
        setProp(Object.keys(data));
        setChartData(data);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();
  }, [startDate, endDate, animalType, grade]);

  let ChartSeries = [];
  if (prop.length > 0) {
    ChartSeries = prop.map((property) => {
      const uniqueValues = chartData[property].values;
      const frequencies = new Array(9).fill(0);

      uniqueValues.forEach((value) => {
        const index = Math.floor(value);
        frequencies[index - 1] += 1;
      });

      return {
        name: property,
        data: frequencies,
      };
    });
  }

  const ChartOption = {
    chart: {
      height: 450,
      type: 'heatmap',
    },
    dataLabels: {
      enabled: false,
    },
    xaxis: {
      type: 'numeric',
      tickAmount: 9, // Number of ticks on the x-axis
      min: 1,
      max: 10, // Adjust the max value as needed
    },
    title: {
      text: '처리육 맛데이터 범위별 분포(빈도수)',
    },
    grid: {
      padding: {
        right: 20,
      },
    },
  };

  return (
    <ApexCharts
      options={ChartOption}
      series={ChartSeries}
      type="heatmap"
      height={350}
    />
  );
}
