class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    users = find_users_from_organization_commented_on(comment)
    Notifier.comment_notification(comment, users).deliver if users.present?
  end

  def find_users_from_organization_commented_on(comment)
    users = comment.parent_id? ?
      comment.ancestors.map(&:user) : comment.commentable.organization.users
    users = users.reject{|u| u == comment.user} # reject commenter
    users.uniq
  end
end
