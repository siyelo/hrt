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
