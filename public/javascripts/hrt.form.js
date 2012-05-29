var HrtForm = {};

// Autotabs a page using javascript
HrtForm.autoTab = function () {
  var tabindex = 1;
  $('input, select, textarea, checkbox').each(function() {
    if (this.type != "hidden") {
      var $input = $(this);
      $input.attr("tabindex", tabindex);
      tabindex++;
    }
  });
};


// prevents non-numeric characters to be entered in the input field
HrtForm.numericInputField = function (input) {
  $(input).keydown(function(event) {
    // Allow backspace and delete, enter and tab
    var bksp = 46;
    var del = 8;
    var enter = 13;
    var tab = 9;

    if ( event.keyCode == bksp || event.keyCode == del || event.keyCode == enter || event.keyCode == tab ) {
      // let it happen, don't do anything
    } else {
      // Ensure that it is a number or a '.' and stop the keypress
      var period = 190;
      if ((event.keyCode >= 48 && event.keyCode <= 57 ) || event.keyCode == period || event.keyCode >= 37 && event.keyCode <= 40)  {
        // let it happen
      } else {
       event.preventDefault();
      };
    };
  });
};


// warns user when navigating away from page with changed form
HrtForm.observeFormChanges = function (form) {
  var catcher = function () {
    var changed = false;

    if ($(form).data('initialForm') != $(form).serialize()) {
      changed = true;
    }

    if (changed) {
      return 'You have unsaved changes!';
    }
  };

  if ($(form).length) { //# dont bind unless you find the form element on the page
    $('input[type=submit]').click(function (e) {
      $(form).data('initialForm', $(form).serialize());
    });

    $(form).data('initialForm', $(form).serialize());
    $(window).bind('beforeunload', catcher);
  };
};

HrtForm.buildUrl = function (url) {
  var parts = url.split('?');
  if (parts.length > 1) {
    return parts.join('.js?');
  } else {
    return parts[0] + '.js';
  }
};

HrtForm.buildJsonUrl = function (url) {
  var parts = url.split('?');
  if (parts.length > 1) {
    return parts.join('.json?');
  } else {
    return parts[0] + '.json';
  }
};


HrtForm.validateDates = function (startDate, endDate) {
  var checkDates = function (e) {
    var element = $(e.target);
    var d1 = new Date(startDate.val());
    var d2 = new Date(endDate.val());

    // remove old errors
    startDate.parent('li').find('.inline-errors').remove();
    endDate.parent('li').find('.inline-errors').remove();

    if (startDate.length && endDate.length && d1 >= d2) {
      if (startDate.attr('id') == element.attr('id')) {
        message = "Start date must come before End date.";
      } else {
        message = "End date must come after Start date.";
      }
      element.parent('li').append(
        $('<p/>').attr({"class": "inline-errors"}).text(message)
      );
    }
  };

  startDate.live('change', checkDates);
  endDate.live('change', checkDates);
};


HrtForm.initDemoText = function (elements) {
  elements.each(function(){
    var element = $(this);
    var demo_text = element.attr('data-hint');

    if (demo_text != null) {
      element.attr('title', demo_text);
      if (element.val() == '' || element.val() == demo_text) {
        element.val( demo_text );
        element.addClass('input_hint');
      }
    }
  });
};


HrtForm.focusDemoText = function (elements) {
  elements.live('focus', function(){
    var element = $(this);
    var demo_text = element.attr('data-hint');
    if (demo_text != null) {
      if (element.val() == demo_text) {
        element.val('');
        element.removeClass('input_hint');
      }
    }
  });
};

HrtForm.removeDemoText = function (elements) {
  elements.each(function () {
    var element = $(this);
    var demo_text = element.attr('data-hint');
    if (demo_text != null) {
      if (element.val() == demo_text) {
        element.val('');
      }
    }
  });
};

HrtForm.blurDemoText = function (elements) {
  elements.live('blur', function(){
    var element = $(this);
    var demo_text = element.attr('data-hint');
    if (demo_text != null) {
      if (element.val() == '') {
        element.val( demo_text );
        element.addClass('input_hint');
      }
    }
  });
};

HrtForm.hideAll = function() {
  $('#activity_project_id').val(-1);
  $('#other_cost_project_id').val('');
  $('#projects_listing').hide();
  $('#new_project_form').hide();
  $('#new_activity_form').hide();
  $('#new_other_cost_form').hide();
  $('.js_total_budget .amount, .js_total_spend .amount').html(0);
};

HrtForm.toggleCollapsed = function (elem, indicator) {
  var is_visible = elem.is(':visible');
  if (is_visible) {
    indicator.removeClass('collapsed');
  } else {
    indicator.addClass('collapsed');
  };
};

HrtForm.unsavedWarning = function () {
  return 'You have projects that have not been saved.  Saved projects show a green checkmark next to them.  Are you sure you want to leave this page?'
};
