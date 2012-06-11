var HrtLandingPage = {};

HrtLandingPage.init = function () {
  $('#password_reset').click(function (e) {
    e.preventDefault();
     $('#login_form').fadeOut(function () {
      $('#admin').removeClass('login_form_opacity')
       $('#password_reset_form').fadeIn();
     });
  });

  $('#sign_in').click(function (e) {
    e.preventDefault();
     $('#password_reset_form').fadeOut(function () {
       $('#login_form').fadeIn();
     });
  });

  $('.js_pagination a').live('click', function (e) {
    e.preventDefault();
    var link = $(this).attr('href');
    $.get(link, function (data) {
      $('#js_files_download').replaceWith(data);
    })
  });
};
