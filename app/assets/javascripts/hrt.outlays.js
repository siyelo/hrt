var HrtOutlays = {};

HrtOutlays.init = function () {
  $('#activity_project_id').change(function () {
    update_funding_source_selects();
  });

  $('#activity_name').live('keyup', function() {
    var parent = $(this).parent('li')
    var remaining = $(this).attr('data-maxlength') - $(this).val().length;
    $('.remaining_characters').html("(?) <span class=\"red\">" + remaining + " Characters Remaining</span>")
  });

  $('.js_implementer_select').live('change', function(e) {
    e.preventDefault();
    var element = $(this);
    if (element.val() == "-1") {
      $('.js_implementer_container').hide();
      $('.add_organization').show();
    }
  });

  $('.js_target_field').live('keydown', function (e) {
    var block = $(this).parents('.js_targets');

    if (e.keyCode === 13) {
      e.preventDefault();
      block.find('.js_add_nested').trigger('click');
      block.find('.js_target_field:last').focus()
    }
  });

  $('.js_implementer_spend').live('keyup', function(e) {
    var page_spend = parseFloat($('body').attr('page_spend'));
    var current_spend = Hrt.implementerPageTotal('spend');
    var difference = page_spend - current_spend;
    var total = parseFloat($('body').attr('total_spend'));
    $('.js_total_spend').find('.amount').html((total - difference).toFixed(2))
  });

  $('.js_implementer_budget').live('keyup', function(e) {
    var page_budget = parseFloat($('body').attr('page_budget'));
    var current_budget = Hrt.implementerPageTotal('budget');
    var difference = page_budget - current_budget;
    var total = parseFloat($('body').attr('total_budget'));
    $('.js_total_budget').find('.amount').html((total - difference).toFixed(2))
  });

  if ($('.js_target_field').size() == 0) {
    $(document).find('.js_add_nested').trigger('click');
  }

  $('.ui-autocomplete-input').live('focusin', function () {
    var element = $(this).siblings('select');
    if(element.children('option').length < 2) { // because there is already one in to show default
      element.append(selectOptions);
    }
  });

  HrtForm.numericInputField(".js_implementer_spend, .js_implementer_budget");
  HrtComments.init();
  Hrt.dynamicUpdateTotalsInit();
  Hrt.storeImplementerPageTotal();
};

