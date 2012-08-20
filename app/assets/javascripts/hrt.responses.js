var HrtResponses = {};

HrtResponses.rejectAndComment = function (form, formArray, response_id) {
  $.post(HrtForm.buildJsonUrl(form.attr('action')),
      $.param(formArray), function (data, status, response) {
    if (response.status === 206) {
      ajaxLoader.hide();
      element.removeClass('disabled');
      form.replaceWith(data.html);
    } else {
      $.get('/responses/' + response_id + '/reject', '',
        function(data, status, response) {
          window.location.reload();
      });
    }
  });
};
