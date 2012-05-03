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

  // choose either the full version
  $(".multiselect").multiselect({sortable: false});
  // or disable some features
  //$(".multiselect").multiselect({sortable: false, searchable: false});

  toggleMultiselect($('#user_roles'));

  $('#user_roles').change(function () {
    toggleMultiselect($(this));
  });
};
