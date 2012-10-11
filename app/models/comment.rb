class Comment < ActiveRecord::Base

  REMOVED_MESSAGE = "This comment has been removed by sysadmin."

  acts_as_tree order: 'created_at DESC'

  ### Attributes
  attr_accessible :comment, :parent_id

  ### Validations
  validates_presence_of :comment, :user_id, :commentable_id, :commentable_type

  ### Associations
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  ### Named scopes
  scope :on_all, lambda { |dr_ids|
    { joins: "LEFT OUTER JOIN projects p ON p.id = comments.commentable_id
                 LEFT OUTER JOIN data_responses dr ON dr.id = comments.commentable_id
                 LEFT OUTER JOIN activities a ON a.id = comments.commentable_id
                 LEFT OUTER JOIN activities oc ON oc.id = comments.commentable_id ",
      conditions: ["(comments.commentable_type = 'DataResponse'
                          AND dr.id IN (:drs))
                        OR (comments.commentable_type = 'Project'
                          AND p.data_response_id IN (:drs))
                        OR (comments.commentable_type = 'Activity'
                          AND a.type IS NULL
                          AND a.data_response_id IN (:drs))
                        OR (comments.commentable_type = 'Activity'
                          AND oc.type = 'OtherCost'
                          AND oc.data_response_id IN (:drs))",
                       {drs: dr_ids}],
     order: "comments.created_at DESC" }
  }
  scope :published, where(removed: false)
  scope :removed, where(removed: true)

  def self.recent_comments(data_responses)
    Comment.on_all(data_responses.map{|r| r.id}).limit(10)
  end
end

