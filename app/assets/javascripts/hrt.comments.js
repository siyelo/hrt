var HrtComments = {};

HrtComments.init = function () {
  HrtForm.initDemoText($('*[data-hint]'));
  HrtForm.focusDemoText($('*[data-hint]'));
  HrtForm.blurDemoText($('*[data-hint]'));

  var removeInlineErrors = function (form) {
    form.find('.inline-errors').remove(); // remove inline error if present
  }

  $('.js_reply').live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    element.parents('li:first').find('.js_reply_box:first').show();
  })

  $('.js_cancel_reply').live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    element.parents('.js_reply_box:first').hide();
    removeInlineErrors(element.parents('form'));
  })

  // remove demo text when submiting comment
  $('.js_submit_comment_btn').live('click', function (e) {
    e.preventDefault();
    HrtForm.removeDemoText($('*[data-hint]'));

    var element = $(this);
    if (element.hasClass('disabled')) {
      return;
    }

    var form    = element.parents('form');
    var block;
    var ajaxLoader = element.parent('li').nextAll('.ajax-loader');

    element.addClass('disabled');
    ajaxLoader.show();

    $.post(HrtForm.buildJsonUrl(form.attr('action')), form.serialize(),
        function (data, status, response) {
      ajaxLoader.hide();
      element.removeClass('disabled');

      if (response.status === 206) {
        form.replaceWith(data.html)
      } else {
        form.find("p.input-errors").remove();
        if (form.find('#comment_parent_id').length) {
          // comment reply
          block = element.parents('li.comment_item:first');

          if (block.find('ul').length) {
            block.find('ul').prepend(data.html);
          } else {
            block.append($('<ul/>').prepend(data.html));
          }
        } else {
          // root comment
          block = $('ul.js_comments_list');
          block.prepend(data.html)
        }
      }

      HrtForm.initDemoText(form.find('*[data-hint]'));
      removeInlineErrors(form);
      form.find('textarea').val(''); // reset comment value to blank
      form.find('.js_cancel_reply').trigger('click'); // close comment block
    });
  });
};
