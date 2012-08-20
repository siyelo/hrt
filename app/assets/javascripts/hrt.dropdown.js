var HrtDropdown = {
  // find the dropdown menu relative to the current element
  menu: function(element){
    return element.parents('.js_dropdown_menu');
  },

  toggle_on: function (menu_element) {
    menu_element.find('.menu_items').slideDown(100);
    menu_element.addClass('persist');
  },

  toggle_off: function (menu_element) {
    menu_element.find('.menu_items').slideUp(100);
    menu_element.removeClass('persist');
  }
};

HrtDropdown.init = function () {
  $('.js_dropdown_trigger').click(function (e){
    e.preventDefault();
    menu = HrtDropdown.menu($(this));
    if (!menu.is('.persist')) {
      HrtDropdown.toggle_on(menu);
    } else {
      HrtDropdown.toggle_off(menu);
    };
    e.stopPropagation();
  });

  $(document).click(function(e) {
    HrtDropdown.toggle_off($(this));
  });

  $('.js_dropdown_menu .menu_items a').click(function (e){
    menu = HrtDropdown.menu($(this));
    HrtDropdown.toggle_off(menu);
    $(this).click; // continue with desired click action
  });
};

