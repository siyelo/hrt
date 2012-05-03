var HrtLandingPage = {};

HrtLandingPage.init = function () {
  $('#password_reset').click(function (e) {
    e.preventDefault();
     $('#new_user_session').fadeOut(function () {
      $('#admin').removeClass('login_form_opacity')
       $('#new_password_reset').fadeIn();
     });
  });

  $('#sign_in').click(function (e) {
    e.preventDefault();
     $('#new_password_reset').fadeOut(function () {
       $('#new_user_session').fadeIn();
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
