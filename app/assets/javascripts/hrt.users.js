var HrtUsers = {};

HrtUsers.init = function () {
  var toggleMultiselect = function (element) {
    var ac_selected = $('#user_roles option[value="activity_manager"]:selected').length > 0;
    if (element.val() && ac_selected) {
      $(".organizations").show().css('visibility', 'visible');
      $(".js_manage_orgs").slideDown();
    } else {
      $(".js_manage_orgs").slideUp();
      $(".organizations").hide().css('visibility', 'hidden');
    }
  };

  toggleMultiselect($('#user_roles'));

  $('#user_roles').change(function () {
    toggleMultiselect($(this));
  });
};
