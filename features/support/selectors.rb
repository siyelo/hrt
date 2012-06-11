# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file is used by web_steps.rb, which you should also delete
#
# You have been warned
module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator

    when "the page"
      "html > body"

    when /the selected data response sub-tab/
      "#data_response_sub_tabs.tabs_nav ul li.selected"

    when /the selected project sub-tab/
      ".project_sub_tabs.tabs_nav ul li.selected"

    when /the selected activity sub-tab/
      ".activity_sub_tabs.tabs_nav ul li.selected"

    when /the budget coding tab/
      "#tab1"

    when /the budget districts tab/
      "#tab2"

    when /the budget cost categorization tab/
      "#tab3"

    when /the expenditure coding tab/
      "#tab5"

    when /the expenditure districts tab/
      "#tab6"

    when /the expenditure cost categorization tab/
      "#tab7"

    when /the main nav/
      "#main-nav"

    when /the sub nav/
      "#sub-nav"

    when /the admin nav/
      "#admin"

    when /the group tab/
      "ul#group"

    when /the table heading/
      "thead"

    when /the 2nd row of the table/
      "tbody tr:nth-child(2)"

    when /a link in the 2nd row of the table/
      "tbody tr:nth-child(2) td a"

    when /the 1st row of the table/
      "tbody tr:nth-child(1)"

    when /a link in the 1st row of the table/
      "tbody tr:nth-child(1) td a"

    when /a link in the filters list/
      "ul.section_nav li a"

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #  when /^the (notice|error|info) flash$/
    #    ".flash.#{$1}"

    # You can also return an array to use a different selector
    # type, like:
    #
    #  when /the header/
    #    [:xpath, "//header"]

    # This allows you to provide a quoted selector as the scope
    # for "within" steps as was previously the default for the
    # web steps:
    when /^"(.+)"$/
      $1

    else
      raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
