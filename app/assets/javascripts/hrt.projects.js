var HrtProjects = {};

HrtProjects.init = function () {
  // use click() not toggle() here, as toggle() doesnt
  // work when menu items are also toggling it

  $('.js_upload_btn').click(function (e) {
    e.preventDefault();
    $(this).parents('tbody').find('.upload_box').slideToggle();
  });

  $('#import_export').click(function (e) {
    e.preventDefault();
    $('#import_export_box .upload_box').slideToggle();
  });

  $('.tooltip_projects').tipsy({gravity: $.fn.tipsy.autoWE, live: true, html: true});

  HrtComments.init();

  $('.js_reject_button').click(function (e) {
    e.preventDefault();
    var element = $(this);
    if (element.hasClass('disabled')) {
      return;
    }

    var form = element.parents('form');
    var ajaxLoader = element.parent('li').nextAll('.js_ajax_loader').find('img');
    var formArray = form.serializeArray();

    element.addClass('disabled');
    ajaxLoader.show();

    for (index = 0; index < formArray.length; ++index) {
      if (formArray[index].name == "comment[comment]") {
        formArray[index].value = 'Response rejected: ' + formArray[index].value;
        break
      }
    };

    HrtResponses.rejectAndComment(form, formArray, $('#reject_link').data('response_id'));
  });

  $('.js_address').address(function() {
    return 'new_' + $(this).data('type');
  });

  $.address.externalChange(function() {
    var hash = $.address.path();
    if (hash == '/'){
      if (!($('#projects_listing').is(":visible"))){
        $('.js_toggle_projects_listing').click();
      }
    } else {
      if (hash == '/new_project'){
        HrtForm.hideAll();
        $('#new_project_form').removeClass('hidden');
        $('#new_project_form').fadeIn();
        HrtForm.validateDates($('.start_date'), $('.end_date'));
      } else if (hash == '/new_activity'){
        HrtForm.hideAll();
        $('#new_activity_form').removeClass('hidden');
        $('#new_activity_form').fadeIn();
        HrtOutlays.init();
      }
      else if (hash == '/new_other_cost'){
        HrtForm.hideAll();
        $('#new_other_cost_form').removeClass('hidden');
        $('#new_other_cost_form').fadeIn();
      }
    };
  });

  $('.js_toggle_project_form').click(function (e) {
    e.preventDefault();
    HrtForm.hideAll();
    $('#new_project_form').removeClass('hidden');
    $('#new_project_form').fadeIn();
    $('#new_project_form #project_name').focus();
  });

  $('.js_toggle_activity_form').click(function (e) {
    e.preventDefault();
    HrtForm.hideAll();
    $('#new_activity_form').removeClass('hidden');
    $('#new_activity_form').fadeIn();
    $('#activity_project_id').val($(this).data('project'));
    $('#new_activity_form #activity_name').focus();
    HrtOutlays.init();
  });

  $('.js_toggle_other_cost_form').click(function (e) {
    e.preventDefault();
    HrtForm.hideAll();
    $('#new_other_cost_form').removeClass('hidden');
    $('#new_other_cost_form').show();
    $('#other_cost_project_id').val($(this).data('project'));
    $('#new_other_cost_form #other_cost_name').focus();
  });

  $('.js_toggle_projects_listing').click(function (e) {
    e.preventDefault();
    HrtForm.hideAll();
    $.address.path('/');
    $( "form" )[ 0 ].reset()
    $('#projects_listing').show();
    $("html, body").animate({ scrollTop: 0 }, 0);
  });

  Hrt.dynamicUpdateTotalsInit();
  HrtForm.numericInputField(".js_spend, .js_budget");
};


HrtProjects.importInit = function () {
  $('.activity_box .header').live('click', function (e) {
    e.preventDefault();
    var activity_box = $(this).parents('.activity_box');
    //collapse the others, in an accordion style
    $.each($.merge(activity_box.prevAll('.activity_box'), activity_box.nextAll('.activity_box')), function () {
      $(this).find('.js_main').hide();
      HrtForm.toggleCollapsed($(this).find('.js_main'), $(this).find('.header span'));
    });

    activity_box.find('.js_main').toggle();
    HrtForm.toggleCollapsed(activity_box.find('.js_main'), activity_box.find('.header span'));
  });

  $('.header:first').trigger('click'); // expand the first one on page load

  $(window).bind('beforeunload',function (e) {
    if ($('.js_unsaved').length > 0) {
      return HrtForm.unsavedWarning();
    }
  });

  $('.save_btn').live('click', function (e) {
    // e.preventDefault();
    var element = $(this);
    var ajaxLoader = element.next('.ajax-loader');
    ajaxLoader.show();
  });
};
