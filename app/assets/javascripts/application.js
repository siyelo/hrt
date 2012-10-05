// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require 'vendor'
//= require 'hrt'
//= require 'hrt.form'
//= require 'hrt.nested_forms'
//= require 'hrt.charts'
//= require 'hrt.organizations'
//= require 'hrt.classification'
//= require 'hrt.comments'
//= require 'hrt.dropdown'
//= require 'hrt.projects'
//= require 'hrt.outlays'
//= require 'hrt.users'
//= require 'hrt.reports'
//= require 'hrt.landing_page'
//= require 'hrt.dashboard'
//= require 'hrt.responses'



// Page scopes
var reports_index = {
  run: function () {
    HrtCharts.drawPieChart($('.projects_tab .code_spent')[0],
        _expenditure_summary, _expenditure_colours, 450, 300, _links);
    HrtCharts.drawPieChart($('.projects_tab .code_budget')[0],
        _budget_summary, _budget_colours, 450, 300, _links);
    HrtReports.tabInit();
  }
};

var reports_projects_show = {
  run: function () {
    HrtCharts.drawPieChart($('.code_spent')[0],
        _expenditure_summary, _expenditure_colours, 450, 300, _links);
    HrtCharts.drawPieChart($('.code_budget')[0],
        _budget_summary, _budget_colours, 450, 300, _links);
    HrtReports.tabInit();
  }
};

var reports_activities_show = {
  run: function () {
    HrtCharts.drawPieChart($('.code_spent')[0],
        _expenditure_summary, _expenditure_colours, 450, 300, _links);
    HrtCharts.drawPieChart($('.code_budget')[0],
        _budget_summary, _budget_colours, 450, 300, _links);
    HrtReports.tabInit();
  }
};

var admin_reports_index = {
  run: function () {
    HrtCharts.drawColumnChart($('.code_spent')[0],
        _expenditure_summary, _expenditure_colours,
        450, 300, _max_percentage);
    HrtCharts.drawColumnChart($('.code_budget')[0],
        _budget_summary, _budget_colours,
        450, 300, _max_percentage);
    HrtReports.tabInit();
  }
}

var admin_reports_detailed_index = {
  run: function () {
    $('.mark_double_counts').click(function (e) {
      var element = $(this);
      var parent_tr = element.parents('tr:first')
      var double_count_tr = parent_tr.next('tr');

      if (double_count_tr.hasClass('hidden')) {
        double_count_tr.removeClass('hidden');
        element.addClass('hovered');
        parent_tr.addClass('connect');
      } else {
        double_count_tr.addClass('hidden');
        element.removeClass('hovered');
        parent_tr.removeClass('connect');
      }
    });
  }
}

var admin_purposes_index = admin_inputs_index = {
  run: function () {
    $('.js_code_row').live('click', function (e) {
      var element = $(this);
      var icon = element.find('span.js_icon:first');

      // change +/- icon
      if (icon.text() === "+") {
        icon.html("-");
      } else {
        icon.html("+");
      }

      // collapse-expand children codes
      $("#" + element.attr("id") + "_act").slideToggle();
    });
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
    HrtProjects.importInit();
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

var dashboard_index ={
  run: function () {
    HrtDashboard.init()
  }
};

// DOM LOAD
$(function () {
  HrtDropdown.init();

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

  $( ".js_autocomplete").live("keydown.autocomplete", function () {
    $(this).autocomplete({
      source: "/organizations.json",
      minLength: 2
    });
  });

  // jquery multiselect
  $(".multiselect").multiselect();

  // print pages
  $('#print-page').click(function (e) {
    e.preventDefault();
    window.print();
  });

  // Scope javascript by page id
  var id = $('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof(window[controller_action]) !== 'undefined' &&
        typeof(window[controller_action]['run']) === 'function') {
      window[controller_action]['run']();
    }
  };
});
