var HrtReports = {};

HrtReports.tabInit = function () {
  $('.nav-tab').click(function (e) {
    e.preventDefault();
    var element = $(this);
    var tabName = element.data('tab');
    var report  = element.data('report');
    var tab     = $('#charts_tables .' + tabName);

    $('#charts_tables > div').hide();
    tab.show();
    $('#tabs-container a').removeClass('active')
    element.addClass('active');
    if (!tab.data('loaded')) {
      HrtReports.loadTab(tabName, report);
    }
  });
};

HrtReports.loadTab = function (tabName, report) {
  var tab = $('#charts_tables .' + tabName);
  tab.load(tab.data('url'), function() {
    if (tab.data('chart') == 'column') {
      HrtReports.loadColumnCharts(tabName);
    } else {
      HrtReports.loadPieCharts(tabName);
    }
    tab.data('loaded', true);
  });
};

HrtReports.loadColumnCharts = function (tabName) {
  HrtCharts.drawColumnChart($('.' + tabName + ' .code_spent')[0],
    _expenditure_summary, _expenditure_colours, 450, 300, _max_percentage);
  HrtCharts.drawColumnChart($('.' + tabName + ' .code_budget')[0],
    _budget_summary, _budget_colours, 450, 300, _max_percentage);
};

HrtReports.loadPieCharts = function (tabName) {
  HrtCharts.drawPieChart($('.' + tabName + ' .code_spent')[0],
    _expenditure_summary, _expenditure_colours, 450, 300);
  HrtCharts.drawPieChart($('.' + tabName + ' .code_budget')[0],
    _budget_summary, _budget_colours, 450, 300);
};
