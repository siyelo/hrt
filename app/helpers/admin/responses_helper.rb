module Admin::ResponsesHelper

  def search_and_filter_responses(count, query, filter)
    message = "Found #{pluralize(count, "responses")}"
    if query
      message += " matching <span class='bold'>#{query}</span>"
    end
    if filter && filter != "All"
      message += " that are <span class='bold'>#{filter}</span>"
    end
    if query || (filter && filter != "All")
      message += ". #{link_to "(Back to all responses)", admin_responses_url}"
    end

    message.html_safe
  end
end
