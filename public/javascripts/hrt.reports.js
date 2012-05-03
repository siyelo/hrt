var HrtReports = {};

HrtReports.tabInit = function () {
  $('.nav-tab').click(function (e) {
    e.preventDefault();
    $("#code_spent").hide();
    $("#code_budget").hide();
    $("#report-data").hide();
    $('.ajax-loader').show();
    HrtReports.loadTab($(this).attr('id'));
    $('#tabs-container a').removeClass('active')
    $(this).addClass('active');
  });
};

HrtReports.loadTab = function (tab) {
  $.get('/reports/' + tab, function(data) {
    $("#code_spent").hide();
    $("#code_budget").hide();
    $("#report-data").hide();
    $('.ajax-loader').show();
    $('#charts_tables').html(data);
      HrtCharts.drawPieChart('code_spent', _expenditure_summary, 450, 300);
      HrtCharts.drawPieChart('code_budget', _budget_summary, 450, 300);
  });
};
