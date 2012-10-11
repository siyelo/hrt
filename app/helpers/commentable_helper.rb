module CommentableHelper
  def commentable_url(comment)
    commentable = comment.commentable
    url = case comment.commentable_type
    when "Project"
      edit_project_url(commentable, response_id: commentable.data_response.id)
    when "Activity"
      edit_activity_url(commentable, response_id: commentable.data_response.id)
    when "OtherCost"
      edit_other_cost_url(commentable, response_id: commentable.data_response.id)
    when "DataResponse"
      projects_url(response_id: commentable.id)
    end

    "#{url}##{dom_id(comment)}"
  end

  def commentable_name(type, commentable, user)
    case type
    when "FundingFlow"
      (commentable.try(:to) == user.organization) ?
        "Funding Source" : "Implementer"
    when "OtherCost"
      "Indirect Cost"
    else
      type
    end
  end
end

