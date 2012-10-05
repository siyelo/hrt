class DataRequest < ActiveRecord::Base
  ### Attributes
  attr_accessible :organization_id, :title, :start_date

  ### Associations
  belongs_to :organization
  has_many :data_responses, :dependent => :destroy
  has_many :reports, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :title, :start_date
  validates_date :start_date

  ### Callbacks
  before_create :set_code_type_versions
  after_create :create_data_responses

  ### Named scopes
  scope :sorted, { :order => "data_requests.start_date DESC" }

  alias_attribute :name, :title

  ### Instance Methods

  def end_date
    start_date + (1.year - 1.day)
  end

  def previous_request
    find_request(:previous)
  end

  def next_request
    find_request(:next)
  end

  def destroy_and_clean_response_references
    transaction do
      self.destroy
    end
  end
  handle_asynchronously :destroy_and_clean_response_references

  private
  def set_code_type_versions
    self.locations_version     = Location.last_version
    self.purposes_version      = Purpose.last_version
    self.inputs_version        = Input.last_version
    self.beneficiaries_version = Beneficiary.last_version
  end

  def create_data_responses
    transaction do
      if previous_request
        ResponseCloner.new(previous_request, self).deep_clone!
      else
        Organization.reporting.all.each do |organization|
          organization.create_data_responses!
        end
      end
    end
  end
  handle_asynchronously :create_data_responses

  def find_request(direction)
    order = direction == :previous ? 'ASC' : 'DESC'
    requests = DataRequest.find(:all, :order => "start_date #{order}")
    index = requests.index(self)
    index == 0 ? nil : requests[index - 1]
  end
end

# == Schema Information
#
# Table name: data_requests
#
#  id              :integer         not null, primary key
#  organization_id :integer
#  title           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  start_date      :date
#

