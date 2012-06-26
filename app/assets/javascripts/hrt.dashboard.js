var HrtDashboard = {};

HrtDashboard.init = function () {
  $('.contact_expander').click(function (e) {
    e.preventDefault();
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
};
