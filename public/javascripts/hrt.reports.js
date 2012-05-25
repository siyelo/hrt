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
      HrtReports.loadColumnCharts(tabName, _expenditure_summary, _budget_summary,
        _max_percentage);
    } else {
      HrtReports.loadPieCharts(tabName, _expenditure_summary, _budget_summary);
    }
    tab.data('loaded', true);
  });
};

HrtReports.loadColumnCharts = function (tabName, spendData, budgetData, maxPercentage) {
  HrtCharts.drawColumnChart($('.' + tabName + ' .code_spent')[0],
    spendData, 450, 300, maxPercentage);
  HrtCharts.drawColumnChart($('.' + tabName + ' .code_budget')[0],
    budgetData, 450, 300, maxPercentage);
};

HrtReports.loadPieCharts = function (tabName, spendData, budgetData) {
  HrtCharts.drawPieChart($('.' + tabName + ' .code_spent')[0], spendData, 450, 300);
  HrtCharts.drawPieChart($('.' + tabName + ' .code_budget')[0], budgetData, 450, 300);
};
