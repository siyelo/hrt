# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file is used by web_steps.rb, which you should also delete
#
# You have been warned
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the dashboard/
      dashboard_path

    when /admin files/
      admin_documents_path

    when /the activities page/
      activities_path

    when /the admin comments page/
      admin_comments_path

    when /the organizations page/
      organizations_path

    when /the implementers page/
      implementers_path

    when /the purpose split page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, mode: 'purposes')

    when /the location split page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, mode: 'locations')

    when /the input split page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, mode: 'inputs')

    when /the output edit page for "(.+)"/
      activity = Activity.find_by_name($1)
      edit_activity_or_ocost_path(activity, mode: 'outputs')

   when /the edit project page for related activity "(.+)"/
      activity = Activity.find_by_name($1)
      edit_response_project_path(activity.response, activity.project)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
