var HrtReports = {};

HrtReports.tabInit = function () {
  HrtReports.hideDoubleCountCheckbox();
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
    HrtReports.hideDoubleCountCheckbox();
    if (!tab.data('loaded')) {
      HrtReports.loadTab(tabName, report);
    }
  });
  $('#include_double_count').change(function (e) {
    e.preventDefault();
    var doubleCount = $(this).is(':checked');
    var activeTab = $('#tabs-container').find('.active');
    var tabName = activeTab.data('tab');
    var report  = activeTab.data('report');

    activeTab.data('double-count', doubleCount.toString());
    $('.include_double_count .ajax-loader').removeClass('hidden');
    HrtReports.loadTab(tabName, report, doubleCount);
  });

  $('#export-report').click(function (e) {
    e.preventDefault();
    var tab = $('#charts_tables .' + $('.nav-tab.active').data('tab'));
    var url = tab.data('url').split('?').join('.xls?') +
              '&double_count=' + $('#include_double_count').is(':checked')
    window.location = url;
  });
};

HrtReports.loadTab = function (tabName, report, include_double_count) {
  var tab = $('#charts_tables .' + tabName);

  url = tab.data('url')
  if (url.indexOf('?') > -1) {
    url += '&double_count=' + include_double_count
  } else {
    url += '?double_count=' + include_double_count
  }

  tab.load(url, function() {
    if (tab.data('chart') == 'column') {
      HrtReports.loadColumnCharts(tabName);
    } else {
      HrtReports.loadPieCharts(tabName);
    }
    tab.data('loaded', true);
    $('.include_double_count .ajax-loader').addClass('hidden');
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

HrtReports.hideDoubleCountCheckbox = function () {
  var report = $('#tabs-container').find('.active').data('report');
  var activeTab = $('#tabs-container').find('.active');
  var doubleCount = activeTab.data('double-count') === 'true'
  $('#include_double_count').attr('checked', doubleCount);

  if( $.inArray(report, ['reporters', 'funders', 'locations']) >= 0 ) {
    $('.include_double_count').removeClass('hidden');
  } else {
    $('.include_double_count').addClass('hidden');
  }
};
