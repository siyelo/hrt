var Hrt = {};

Hrt.implementerPageTotal = function (type) {
  var page_total = 0;

  inputs = (type == 'budget') ? $('.js_implementer_budget') : $('.js_implementer_spend');

  inputs.each(function () {
    float_val = parseFloat($(this).val());
    if ( !(isNaN(float_val)) ) {
      page_total += parseFloat($(this).val());
    }
  });

  return page_total;
};

Hrt.storeImplementerPageTotal = function(){
  $('body').attr('total_spend', $('.js_total_spend').find('.amount').html() )
  $('body').attr('total_budget', $('.js_total_budget').find('.amount').html() )

  if ( $('.js_implementer_budget').length > 0 ) {
    page_budget = Hrt.implementerPageTotal('budget');
    $('body').attr('page_budget',page_budget);
  }

  if ( $('.js_implementer_spend').length > 0 ) {
    page_spend = Hrt.implementerPageTotal('spend');
    $('body').attr('page_spend',page_spend);
  }
};

Hrt.updateTotalValue = function (el) {
  if ($(el).hasClass('js_spend')) {
    if ($(el).parents('table').length) {
      // table totals
      var table        = $(el).parents('table');
      var input_fields = table.find('input.js_spend:visible');
      var total_field  = table.find('.js_total_spend .amount');
    } else {
      // classifications tree totals
      var input_fields = $(el).parents('.activity_tree').find('> li > div input.js_spend');
      var total_field  = $('.js_total_spend .amount');
    }
  } else if ($(el).hasClass('js_budget')) {
    if ($(el).parents('table').length) {
      // table totals
      var table = $(el).parents('table');
      var input_fields = table.find('input.js_budget:visible');
      var total_field = table.find('.js_total_budget .amount');
    } else {
      // classifications tree totals
      var input_fields = $(el).parents('.activity_tree').find('> li > div input.js_budget');
      var total_field = $('.js_total_budget .amount');
    }
  } else {
    throw "Element class not valid";
  }

  var fieldsTotal = Hrt.getFieldsTotal(input_fields);
  total_field.html(fieldsTotal.toFixed(2));
};

Hrt.dynamicUpdateTotalsInit = function () {
  $('.js_spend, .js_budget').live('keyup', function () {
    Hrt.updateTotalValue(this);
  });
};

Hrt.getFieldsTotal = function (fields) {
  var total = 0;

  for (var i = 0; i < fields.length; i++) {
    if (!isNaN(fields[i].value)) {
      total += Number(fields[i].value);
    }
  }

  return total;
};

Hrt.approveBudget = function() {
  $(".js_am_approve").click(function (e) {
    e.preventDefault();
    Hrt.approveActivity($(this), 'activity_manager_approve', 'Budget Approved');
  })
};

Hrt.approveAsAdmin = function() {
  $(".js_sysadmin_approve").click(function (e) {
    e.preventDefault();
    Hrt.approveActivity($(this), 'sysadmin_approve', 'Admin Approved');
  })
};

Hrt.approveActivity = function (element, approval_type, success_text) {
  var activity_id = element.attr('activity-id');

  element.parent('li').find(".ajax-loader").show();
  var url = "/activities/" + activity_id + "/" + approval_type
  $.post(url, {approve: true, "_method": "put",
      authenticity_token: rails_authenticity_token}, function (data) {
    element.parent('li').find(".ajax-loader").hide();
    if (data.status == 'success') {
      element.parent('li').html('<span>' + success_text + '</span>');
    }
  })
};
