module DashboardHelper
  def model_name(model)
    if model.respond_to?(:name)
      model.try(:name).presence || "Unnamed #{model.class.to_s.titleize}"
    else
      "(no title)"
    end
  end

  def render_dashboard
    if current_user.sysadmin?
      render 'sysadmin'
    elsif current_user.activity_manager?
      render 'activity_manager'
    elsif current_user.reporter?
      render 'reporter'
    end
  end

  def response_log_tooltip(data_response)
    tip = data_response.status
    if data_response.response_state_logs.last
      log_name = data_response.response_state_logs.last.user.name
      log_date = data_response.response_state_logs.last.created_at.strftime("%d-%m-%Y")
      tip += "<br/>Actioned by: #{log_name}<br/> Actioned on: #{log_date} "
    else
      tip
    end
  end
end
