module Admin::ResponsesHelper

  def search_and_filter_responses(count, query, filter)
    message = "Found #{pluralize(count, "responses")}"
    if query
      message += " matching <span class='bold'>#{query}</span>"
    end
    if filter && filter != "All"
      message += " with a <span class='bold'>#{filter}</span> response"
    end

    if query || filter
      message += ". #{link_to "(Back to all responses)", admin_responses_url}"
    end

    message
  end

end
