var remove_fields = function (link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
  //$(link).parent().next().hide();

  if ($(link).hasClass('totals_callback')) {
    updateTotalValuesCallback(link);
  }
};

var add_fields = function (link, association, content) {
  // before callback
  before_add_fields_callback(association);

  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");

  if (association === 'in_flows' || association === 'implementer_splits' ) {
    $(link).parents('tr:first').before(content.replace(regexp, new_id));
  } else {
    $(link).parent().before(content.replace(regexp, new_id));
  }

  // after_add_fields_callback(association);
};

var before_add_fields_callback = function (association) {
  if (association === 'funding_sources') {
    close_activity_funding_sources_fields($('.funding_sources .fields'));
  }
};

var updateTotalValuesCallback = function (el) {
  Hrt.updateTotalValue($(el).parents('tr').find('.js_spend'));
  Hrt.updateTotalValue($(el).parents('tr').find('.js_budget'));
};
