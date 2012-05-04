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
    HrtCharts.drawPieChart($('.' + tabName + ' .code_spent')[0], _expenditure_summary, 450, 300);
    HrtCharts.drawPieChart($('.' + tabName + ' .code_budget')[0], _budget_summary, 450, 300);
    tab.data('loaded', true);
  });
};
