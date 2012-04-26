class DataResponse < ActiveRecord::Base
  STATES = ['unstarted', 'started', 'submitted', 'rejected', 'accepted']

  include CurrencyNumberHelper
  include DataResponse::States
  include DataResponse::Totaller
  include DataResponse::ErrorChecker

  ### Attributes
  attr_accessible :data_request_id

  ### Associations
  belongs_to :organization
  belongs_to :data_request
  has_many :projects, :dependent => :destroy
  has_many :activities #leave it to projects to destroy activities
  has_many :normal_activities, :class_name => "Activity",
           :conditions => [ "activities.type IS NULL"]
  has_many :other_costs, :dependent => :destroy
  has_many :implementer_splits, :through => :activities
  has_many :comments, :as => :commentable, :dependent => :destroy

  ### Validations
  validates_presence_of   :data_request_id, :organization_id
  validates_uniqueness_of :data_request_id, :scope => :organization_id
  validates_inclusion_of  :state, :in => STATES

  ### Named scopes
  named_scope :latest_first, {:order => "data_request_id DESC" }
  named_scope :submitted, :conditions => ["state = ?", 'submitted']
  named_scope :started, :conditions => ["state = ?", 'started']
  named_scope :with_request, lambda { |request| {
    :conditions => ["data_request_id = ?", request.id] } }
  named_scope :with_state, lambda { |state| {
    :conditions => ["state = ?", state] } }

  ### Delegates
  delegate :name, :to => :data_request
  delegate :title, :to => :data_request
  delegate :currency, :fiscal_year_start_date, :fiscal_year_end_date,
    :contact_name, :contact_position, :contact_phone_number,
    :contact_main_office_phone_number, :contact_office_location,
    :to => :organization

  ### Callbacks
  before_validation_on_create :set_state

  ### Instance Methods

  def request
    self.data_request
  end

  def name
    data_request.try(:title) # some responses does not have data_requst (bug was on staging)
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

