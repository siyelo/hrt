class DataResponse < ActiveRecord::Base
  STATES = ['unstarted', 'started', 'rejected', 'submitted', 'accepted']

  include DataResponse::States
  include DataResponse::Totaller
  include DataResponse::ErrorChecker
  include AttachmentHelper

  ### Attributes
  attr_accessible :data_request_id, :organization_id

  ### Associations
  belongs_to :organization
  belongs_to :data_request
  has_many :projects, dependent: :destroy
  has_many :activities #leave it to projects to destroy activities
  has_many :response_state_logs
  has_many :normal_activities, class_name: "Activity",
           conditions: [ "activities.type IS NULL"]
  has_many :other_costs, dependent: :destroy
  has_many :implementer_splits, through: :activities
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :previous, class_name: 'DataResponse'

  accepts_nested_attributes_for :projects, :other_costs, allow_destroy: true

  ### Validations
  validates_presence_of   :data_request_id, :organization_id
  validates_uniqueness_of :data_request_id, scope: :organization_id
  validates_inclusion_of  :state, in: STATES

  ### Named scopes
  scope :latest_first, {order: "data_request_id DESC" }
  scope :unstarted, conditions: ["state = ?", 'unstarted']
  scope :started,   conditions: ["state = ?", 'started']
  scope :submitted, conditions: ["state = ?", 'submitted']
  scope :accepted,  conditions: ["state = ?", 'accepted']
  scope :rejected,  conditions: ["state = ?", 'rejected']
  scope :with_request, lambda { |request_id| {
    conditions: ["data_request_id = ?", request_id] } }
  scope :with_state, lambda { |state| {
    conditions: ["state = ?", state] } }

  ### Delegates
  delegate :name, :to => :organization
  delegate :currency, :contact_name, :contact_position, :contact_phone_number,
    :contact_main_office_phone_number, :contact_office_location,
    to: :organization

  ### Callbacks
  before_validation :set_state, on: :create

  ### Attachments
  has_attached_file :expenditure_overview, path:
    AttachmentHelper.attachment_path(
      "response_overview/:id/expenditure.:extension")
  has_attached_file :budget_overview, path:
    AttachmentHelper.attachment_path(
      "response_overview/:id/budget.:extension")

  ### Instance Methods

  def private_expenditure_overview_url
    if private_url?
      expenditure_overview.expiring_url(3600)
    else
      expenditure_overview.url
    end
  end

  def private_budget_overview_url
    if private_url?
      budget_overview.expiring_url(3600)
    else
      budget_overview.url
    end
  end

  def request
    self.data_request
  end

  def destroy_asynchronously
    self.destroy
  end
  handle_asynchronously :destroy_asynchronously

  def title
    "#{name}: #{request.title}"
  end

  private
    def set_state
      self.state = 'unstarted'
    end
end


# == Schema Information
#
# Table name: data_responses
#
#  id              :integer         not null, primary key
#  data_request_id :integer         indexed
#  created_at      :datetime
#  updated_at      :datetime
#  organization_id :integer         indexed
#  state           :string(255)
#  projects_count  :integer         default(0)
#

