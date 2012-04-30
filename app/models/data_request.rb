require 'validators'
class DataRequest < ActiveRecord::Base
  ### Attributes
  attr_accessible :organization_id, :title, :start_date

  ### Associations
  belongs_to :organization
  has_many :data_responses, :dependent => :destroy
  has_many :reports, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :title
  validates_date :start_date

  ### Callbacks
  after_create :create_data_responses

  ### Named scopes
  named_scope :sorted, { :order => "data_requests.start_date" }

  ### Instance Methods

  def name
    title
  end

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
    response_ids = self.data_responses.all.map(&:id)
    users = User.find(:all,
                      :conditions => ['data_response_id_current IN (?)', response_ids])

    transaction do
      users.each do |user|
        user.data_response_id_current = nil
        user.save
      end
      self.destroy
    end
  end
  handle_asynchronously :destroy_and_clean_response_references

  private

  def create_data_responses
    transaction do
      Organization.reporting.all.each do |organization|
        organization.create_data_responses!
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
#  id                :integer         not null, primary key
#  organization_id   :integer
#  title             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  due_date          :date
#  start_date        :date
#  end_date          :date
#  final_review      :boolean         default(FALSE)
#  budget_by_quarter :boolean         default(FALSE)
#

