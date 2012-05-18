// Page scopes
var reports_index = {
  run: function () {
    HrtCharts.drawPieChart($('.projects_tab .code_spent')[0], _expenditure_summary, 450, 300);
    HrtCharts.drawPieChart($('.projects_tab .code_budget')[0], _budget_summary, 450, 300);
    HrtReports.tabInit();
  }
};

var reports_projects_show = {
  run: function () {
    HrtCharts.drawPieChart($('.code_spent')[0], _expenditure_summary, 450, 300);
    HrtCharts.drawPieChart($('.code_budget')[0], _budget_summary, 450, 300);
    HrtReports.tabInit();
  }
};

var reports_activities_show = {
  run: function () {
    HrtCharts.drawPieChart($('.code_spent')[0], _expenditure_summary, 450, 300);
    HrtCharts.drawPieChart($('.code_budget')[0], _budget_summary, 450, 300);
    HrtReports.tabInit();
  }
};

var admin_reports_index = {
  run: function () {
    HrtCharts.drawPieChart($('.code_spent')[0], _expenditure_summary, 450, 300);
    HrtCharts.drawPieChart($('.code_budget')[0], _budget_summary, 450, 300);
    HrtReports.tabInit();
  }
}

var admin_responses_index = {
  run: function () {
    HrtCharts.drawBarChart('response_chart', _responses, 900, 150);
  }
};

var admin_organizations_duplicate = {
  run: function () {
    HrtOrganizations.init();
  }
};

var projects_index = {
  run: function () {
    HrtProjects.init()
  }
};

var projects_import = {
  run: function () {
    HrtProjects.import();
  }
}

var projects_new = projects_create = projects_edit = projects_update = {
  run: function () {
    HrtComments.init();
    HrtForm.validateDates($('.start_date'), $('.end_date'));
    Hrt.dynamicUpdateTotalsInit();
    HrtForm.numericInputField(".js_spend, .js_budget");
  }
};

var activities_new = activities_create = activities_edit = activities_update =
    other_costs_edit = other_costs_new = other_costs_create =
    other_costs_update = {
  run: function () {
    HrtClassification.init();
    HrtOutlays.init();
  }
};

var admin_users_new = admin_users_create = admin_users_edit =
    admin_users_update = {
  run: function () {
    HrtUsers.init();
  }
};

var promo_landing = {
  run: function () {
    HrtLandingPage.init()
  }
};

// DOM LOAD
$(function () {
  // prevent going to top when tooltip clicked
  $('.tooltip').live('click', function (e) {
    if ($(this).attr('href') === '#') {
      e.preventDefault();
    }
  });

  // tipsy tooltips everywhere!
  $('.tooltip').tipsy({
    gravity: $.fn.tipsy.autoWE,
    fade: true,
    live: true,
    html: true
  });

  // tipsy tooltips everywhere!
  $('.tooltip-S').tipsy({
    gravity: 's',
    fade: true,
    live: true,
    html: true
  });

  // combobox everywhere!
  $( ".js_combobox" ).combobox();

  // keep below combobox
  HrtForm.autoTab();

  // jquery tools overlays
  $(".overlay").overlay();

  // observe form changes and alert user if form has unsaved data
  HrtForm.observeFormChanges($('.js_form'));

  // Date picker
  $('.date_picker').live('click', function () {
    $(this).datepicker('destroy').datepicker({
      changeMonth: true,
      changeYear: true,
      yearRange: '2000:2025',
      dateFormat: 'dd-mm-yy'
    }).focus();
  });

  // Close flash message
  $(".closeFlash").click(function (e) {
    e.preventDefault();
    $(this).parents('div:first').fadeOut("slow", function() {
      $(this).show().css({display: "none"});
    });
  });

  // CSV file upload
  $("#csv_file").click( function(e) {
    e.preventDefault();
    $("#import").slideToggle();
  });

  // Show/hide getting started tips
  $('.js_tips_hide').click(function (e) {
    e.preventDefault();
    $('.js_tips_container').fadeOut();
    $.post('/profile/disable_tips', { "_method": "put",
       authenticity_token: rails_authenticity_token });
  });

  // Scope javascript by page id
  var id = $('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof(window[controller_action]) !== 'undefined' &&
        typeof(window[controller_action]['run']) === 'function') {
      window[controller_action]['run']();
    }
  }
});
