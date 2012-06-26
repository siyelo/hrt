var HrtOrganizations = {};

HrtOrganizations.init = function () {
  $("#duplicate_organization_id, #target_organization_id").change(function() {
    var target_id    = $('#target_organization_id').val();
    var duplicate_id = $('#duplicate_organization_id').val();
    HrtOrganizations.getOrganizationInfo(target_id, duplicate_id);
  });

  var target_id    = $('#target_organization_id').val();
  var duplicate_id = $('#duplicate_organization_id').val();
  HrtOrganizations.getOrganizationInfo(target_id, duplicate_id);
};

HrtOrganizations.displayFlashForReplaceOrganization = function (type, message) {
  $('#content .wrapper').prepend(
    $('<div/>').attr({id: 'flashes'}).append(
      $('<div/>').attr({id: type}).text(message)
    )
  );

  // fade out flash message
  $("#" + type).delay(5000).fadeOut(3000, function () {
    $("#flashes").remove();
  });
};

HrtOrganizations.removeOrganizationFromLists = function (duplicate_id) {
  var target_element    = $('#target_organization_id');
  var duplicate_element = $('#duplicate_organization_id');
  var duplicate_option  = duplicate_element.find("option[value='" + duplicate_id + "']");
  var target_option  = target_element.find("option[value='" + duplicate_id + "']");
  var next_option       = duplicate_option.next().val();
  if (next_option) {
    duplicate_element.val(next_option);
    HrtOrganizations.getOrganizationInfo(target_element.val(), next_option);
  } else {
    $('.preview').html('');
  };
  duplicate_option.remove();
  target_option.remove();
};

HrtOrganizations.getOrganizationInfo = function (target_id, duplicate_id) {
  if (target_id && duplicate_id) {
    $.get(target_id + '.js?duplicate_id=' + duplicate_id, function (data) {
      $('.preview').html(data);
    });
  }
};
