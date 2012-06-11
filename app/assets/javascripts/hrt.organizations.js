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

  $("#replace_organization").click(function (e) {
    e.preventDefault();
    var element = $(this);
    var form = element.parents('form')
    if (confirm('Are you sure?')) {
      var duplicate_id = $("#duplicate_organization_id").val();
      $.post(HrtForm.buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
        var data = $.parseJSON(data);
        response.status === 206 ? HrtOrganizations.ReplaceOrganizationErrorCallback(data.message) : HrtOrganizations.ReplaceOrganizationSuccessCallback(data.message, duplicate_id);
      });
    }
  });
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
  var next_option       = duplicate_option.next().val();
  if (next_option) {
    duplicate_element.val(next_option);
    HrtOrganizations.getOrganizationInfo(target_element.val(), next_option);
  } else {
    $('.preview').html('');
  };
  duplicate_option.remove();
};

HrtOrganizations.ReplaceOrganizationSuccessCallback = function (message, duplicate_id) {
  HrtOrganizations.removeOrganizationFromLists(duplicate_id, 'duplicate');
  HrtOrganizations.displayFlashForReplaceOrganization('notice', message);
};

HrtOrganizations.ReplaceOrganizationErrorCallback = function (message) {
  HrtOrganizations.displayFlashForReplaceOrganization('error', message);
};

HrtOrganizations.getOrganizationInfo = function (target_id, duplicate_id) {
  if (target_id && duplicate_id) {
    $.get(target_id + '.js?duplicate_id=' + duplicate_id, function (data) {
      $('.preview').html(data);
    });
  }
};
