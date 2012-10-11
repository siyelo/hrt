class DataRequest < ActiveRecord::Base
  ### Attributes
  attr_accessible :organization_id, :title, :start_date

  ### Associations
  belongs_to :organization
  has_many :data_responses, :dependent => :destroy
  has_many :reports, :dependent => :destroy

  ### Validations
  validates :organization_id, presence: true
  validates :title, presence: true
  validates :start_date, presence: true
  validates_date :start_date

  ### Callbacks
  before_validation :set_code_type_versions, on: :create
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
    self.locations_version     = Location.last_version    || 1
    self.purposes_version      = Purpose.last_version     || 1
    self.inputs_version        = Input.last_version       || 1
    self.beneficiaries_version = Beneficiary.last_version || 1
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
