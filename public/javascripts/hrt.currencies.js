var HrtCurrencies = {};

HrtCurrencies.init = function () {
  $(".currency_label").live("click", function () {
    var element = $(this);
    var id = element.attr('id');
    element.hide();
    element.parent('td').append($("<input id=\'" + id + "\' class=\'currency\' />"));
  });

  $(".currency").live('focusout', function () {
    element = $(this);
    var input_rate = element.val();
    var url = "/admin/currencies/" + element.attr('id');
    $.post(url, { "rate" : input_rate, "_method" : "put",
       authenticity_token: rails_authenticity_token }, function (data) {
      var data = $.parseJSON(data);
      if (data.status == 'success'){
        element.parent('td').children('span').show();
        element.parent('td').children('span').text(data.new_rate);
        element.hide();
      }
    });
  });
};
