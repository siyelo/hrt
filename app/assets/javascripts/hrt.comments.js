var HrtComments = {};

HrtComments.init = function () {
  var removeInlineErrors = function (form) {
    form.find('.inline-errors').remove(); // remove inline error if present
  };

  $('.js_reply').live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    element.parents('li:first').find('.js_reply_box:first').show();
  });

  $('.js_cancel_reply').live('click', function (e) {
    e.preventDefault();
    var element = $(this);
    element.parents('.js_reply_box:first').hide();
    removeInlineErrors(element.parents('form'));
  });

  $('.js_edit_comment').live('click', function (e) {
    e.preventDefault();
    var editCommentLink = $(this);
    var wrapper = editCommentLink.parents('li:first');
    var comment = wrapper.find('.js_comment:first');
    editCommentLink.hide();
    comment.hide();

    $.get(editCommentLink.data('url'), function (data) {
      comment.after(data);
      wrapper.find('.js_cancel_edit_comment:first').show();
    });
  });

  $('.js_cancel_edit_comment').live('click', function (e) {
    e.preventDefault();
    var cancelCommentLink = $(this);
    var wrapper = cancelCommentLink.parents('li.comment_item:first');
    var comment = wrapper.find('.js_comment:first');
    var editCommentLink = wrapper.find('.js_edit_comment:first');
    var form = wrapper.find('.js_form_box:first');
    cancelCommentLink.hide();
    editCommentLink.show();
    form.remove();
    comment.show();
  });

  $('.js_remove_comment').live('click', function (e) {
    e.preventDefault();
    var removeCommentLink = $(this);
    var commentWrapper = removeCommentLink.parents('.js_single_comment:first');

    if (confirm('Are you sure?')) {
      $.post(removeCommentLink.data('url'), {"_method": "delete"}, function (data) {
        commentWrapper.html($('<p/>').attr('class', "removed").text(data.html));
      });
    }
  });

  // remove demo text when submiting comment
  $('.js_submit_comment_btn').live('click', function (e) {
    e.preventDefault();
    HrtComments.submit($(this));
  });
};

HrtComments.submit = function(element) {
  if (element.hasClass('disabled')) {
    return;
  }

  var form    = element.parents('form');
  var block;
  var ajaxLoader = element.parent('li').nextAll('.js_ajax_loader').find('img');

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
      liElement = form.parents('li:first');

      if (form.find('#comment_parent_id').length) {
        // comment reply
        block = element.parents('li.comment_item:first');

        if (block.find('ul').length) {
          block.find('ul').prepend(data.html);
        } else {
          block.append($('<ul/>').prepend(data.html));
        }
      } else {
        if (liElement.hasClass('comment_item')) {
          liElement.replaceWith(data.html);
        } else {
          // root comment
          block = $('ul.js_comments_list');
          block.prepend(data.html);
        }
      }
    }

    form.find('.inline-errors').remove(); // remove inline error if present
    form.find('textarea').val(''); // reset comment value to blank
    form.find('.js_cancel_reply').trigger('click'); // close comment block
  });
};
