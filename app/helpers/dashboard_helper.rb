module DashboardHelper
  def commentable_path(comment, user)
    commentable = comment.commentable
    case comment.commentable_type
    when "Project"
      edit_project_path(commentable, :response_id => commentable.data_response.id)
    when "Activity"
      edit_activity_path(commentable, :response_id => commentable.data_response.id)
    when "OtherCost"
      edit_other_cost_path(commentable, :response_id => commentable.data_response.id)
    when "DataResponse"
      projects_path(commentable, :response_id => commentable.id)
    end
  end

  def commentable_name(type, commentable, user)
    case type
    when "FundingFlow"
      (commentable.try(:to) == user.organization) ?
        "Funding Source" : "Implementer"
    when "OtherCost"
      "Other Cost"
    else
      type
    end
  end

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
end
