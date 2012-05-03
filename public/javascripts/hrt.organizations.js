var HrtOrganizations = {};

HrtOrganizations.init = function () {
  $("#duplicate_organization_id, #target_organization_id").change(function() {
    var organization_id = $(this).val();
    var type = $(this).parents('.box').attr('data-type');
    var box = $('#' + type); // type = duplicate; target
    HrtOrganizations.getOrganizationInfo(organization_id, box);
  });

  HrtOrganizations.getOrganizationInfo($("#duplicate_organization_id").val(), $('#duplicate'));
  HrtOrganizations.getOrganizationInfo($("#target_organization_id").val(), $('#target'));

  $("#replace_organization").click(function (e) {
    e.preventDefault();
    var element = $(this);
    var form = element.parents('form')
    if (confirm('Are you sure?')) {
      var duplicate_id = $("#duplicate_organization_id").val();
      $.post(HrtForm.buildUrl(form.attr('action')), form.serialize(), function (data, status, response) {
        var data = $.parseJSON(data)
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

HrtOrganizations.removeOrganizationFromLists = function (duplicate_id, box_type) {
  $.each(['duplicate', 'target'], function (i, name) {
    var select_element = $("#" + name + "_organization_id");
    var current_option = select_element.find("option[value='" + duplicate_id + "']");

    // remove element from page
    if (name === box_type) {
      var next_option = current_option.next().val();
      if (next_option) {
        select_element.val(next_option);
        // update info block
        HrtOrganizations.getOrganizationInfo(select_element.val(), $('#' + name));
      } else {
        $('#' + name).html('')
      }
    }

    current_option.remove();
  });
};

HrtOrganizations.ReplaceOrganizationSuccessCallback = function (message, duplicate_id) {
  HrtOrganizations.removeOrganizationFromLists(duplicate_id, 'duplicate');
  HrtOrganizations.displayFlashForReplaceOrganization('notice', message);
};

HrtOrganizations.ReplaceOrganizationErrorCallback = function (message) {
  HrtOrganizations.displayFlashForReplaceOrganization('error', message);
};

HrtOrganizations.getOrganizationInfo = function (organization_id, box) {
  if (organization_id) {
    $.get(organization_id + '.js', function (data) {
      box.find('.placer').html(data);
    });
  }
};
