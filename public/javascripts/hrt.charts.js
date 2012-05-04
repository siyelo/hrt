var HrtCharts = {};

HrtCharts.drawBarChart = function (id, rawData, width, height) {
  var data = google.visualization.arrayToDataTable(rawData);

  var formatter = new google.visualization.NumberFormat({fractionDigits: 1, suffix: '%'});
  for (var i = 0; i < rawData[0].length; i++) {
    formatter.format(data, i);
  }

  var chart = new google.visualization.BarChart(document.getElementById(id));
  chart.draw(data, {width: width, isStacked: true,
    height: height, chartArea: {width: 800, height: 80},
    backgroundColor: '#FBFBFB',
    hAxis: {format:"#'%"},
    legend: 'top'
  });
};

HrtCharts.drawPieChart = function (element, data_rows, width, height) {
  if (typeof(data_rows) === "undefined") {
    return;
  }

  var data = new google.visualization.DataTable();
  data.addColumn('string', data_rows.names.column1);
  data.addColumn('number', data_rows.names.column2);
  data.addRows(data_rows.values.length);
  for (var i = 0; i < data_rows.values.length; i++) {
    var value = data_rows.values[i];
    data.setValue(i, 0, value[0]);
    data.setValue(i, 1, value[1]);
  };
  var chart = new google.visualization.PieChart(element);
  chart.draw(data, {width: width, height: height, chartArea: {width: 360, height: 220}});
};
