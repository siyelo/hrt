var HrtDashboard = {};

HrtDashboard.init = function () {
  $('.contact_expander').click(function (e) {
    e.preventDefault();
    e.stopPropagation();
    var element = $(this);
    if (element.hasClass('contact_expander')) {
      element.parent('li').next('li').removeClass('hidden');
      element.text('(less)');
      element.removeClass('contact_expander');
      element.addClass('contact_contracter');
    } else {
      element.parent('li').next('li').addClass('hidden');
      element.text('(more)');
      element.addClass('contact_expander');
      element.removeClass('contact_contracter');
    }
  });

  $('.org_row').click(function (e) {
    e.preventDefault();
    window.location.href = $(this).data('link');
  });

  $('.js_reject_link').click(function(e) {
    HrtDashboard.rejectResponse = $(this).data('response_id');
  });

  $('.js_reject_button').click(function(e) {
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
    formArray = fillFormFields(formArray);

    HrtResponses.rejectAndComment(form, formArray, HrtDashboard.rejectResponse);
  });

  fillFormFields = function(formArray){
    for (index = 0; index < formArray.length; ++index) {
      if (formArray[index].name == "comment[comment]") {
        formArray[index].value = 'Response rejected: ' + formArray[index].value;
      };

      if (formArray[index].name == "comment[commentable_type]") {
        formArray[index].value = 'DataResponse'
      };

      if (formArray[index].name == "comment[commentable_id]") {
        formArray[index].value = HrtDashboard.rejectResponse
      };
    };

    return formArray;
  };
};
