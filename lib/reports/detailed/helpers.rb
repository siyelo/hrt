module Reports::Detailed::Helpers
  # remove me
  include CurrencyNumberHelper # gives n2c method
  include StringCleanerHelper # gives h method

  def codes_cache
    return @codes_cache if @codes_cache

    @codes_cache = {}
    [Purpose, Input, Location].each do |code_klass|
      code_klass.all.each do |code|
        @codes_cache[code.id] = code
      end
    end

    return @codes_cache
  end

  def is_budget?(type)
    if type == :budget
      true
    elsif type == :spend
      false
    else
      raise "Invalid type #{type}".to_yaml
    end
  end

  def project_in_flows(project)
    project ? project.in_flows.map do |f|
      "#{f.from.name}#{organization_funder_type(f.from)}"
    end.sort.join(' | ') : ''
  end

  def organization_funder_type(org)
    org.funder_type ? " (#{org.funder_type})" : ''
  end

  def activity_url(activity)
    Rails.application.routes.url_helpers.edit_activity_url(activity, :response_id => activity.data_response.id)
  end

  def activity_total_method(amount_type)
    'total_' + amount_type.to_s.downcase
  end

  # returns the projects budget type
  def project_budget_type(project)
    if project
      project.budget_type
    else
      "N/A"
    end
  end
end
