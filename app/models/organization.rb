require 'validators'

class Organization < ActiveRecord::Base
  include ActsAsDateChecker
  include Organization::Merger

  ### Constants
  FILE_UPLOAD_COLUMNS = %w[name raw_type fosaid currency]

  ORGANIZATION_TYPES = ['Bilateral', 'Central Govt Revenue',
    'Clinic/Cabinet Medical', 'Communal FOSA', 'Dispensary', 'District',
    'District Hospital', 'Government', 'Govt Insurance', 'Health Center',
    'Health Post', 'International NGO', 'Local NGO', 'MOH central',
    'Military Hospital', 'MoH unit', 'Multilateral', 'National Hospital',
    'Non-Reporting', 'Other ministries', 'Parastatal', 'Prison Clinic',
    'RBC institutions']

  NON_REPORTING_TYPES = ['Clinic/Cabinet Medical', 'Communal FOSA',
    'Dispensary', 'District', 'District Hospital', 'Health Center',
    'Health Post', 'Non-Reporting', 'Other ministries', 'Prison Clinic']

  ### Attributes
  attr_accessible :name, :raw_type, :fosaid, :currency, :fiscal_year_end_date,
    :fiscal_year_start_date, :contact_name, :contact_position, :contact_phone_number,
    :contact_main_office_phone_number, :contact_office_location, :location_id,
    :implementer_type, :funder_type

  ### Associations
  belongs_to :location
  has_many :users # people in this organization
  has_and_belongs_to_many :managers, :join_table => "organizations_managers",
    :class_name => "User" # activity managers
  has_many :data_requests
  has_many :data_responses, :dependent => :destroy
  has_many :dr_activities, :through => :data_responses, :source => :activities

  has_many :out_flows, :class_name => "FundingFlow",
             :foreign_key => "organization_id_from"
  has_many :donor_for, :through => :out_flows, :source => :project

  has_many :implementer_splits # this is NOT project.activity.implementer_splits

  # convenience
  has_many :projects, :through => :data_responses
  has_many :activities, :through => :data_responses

  ### Validations
  validates_presence_of :name, :raw_type, :currency
  validates_uniqueness_of :name
  validates_inclusion_of :currency, :in => Money::Currency::TABLE.map{|k, v| "#{k.to_s.upcase}"}
  validates_date :fiscal_year_start_date, :fiscal_year_end_date, :allow_blank => true
  validates_presence_of :fiscal_year_start_date,
   :if => Proc.new { |model| model.fiscal_year_end_date.present? }
  validate :validates_date_range,
   :if => Proc.new { |model| model.fiscal_year_start_date.present? }

  ### Callbacks
  after_create :create_data_responses
  before_destroy :check_no_requests
  before_destroy :check_no_funder_references
  before_destroy :check_no_implementer_references

  ### Delegates
  delegate :name, :to => :location, :prefix => true, :allow_nil => true # gives you location_name - oh lordy!

  ### Named scopes
  named_scope :without_users, :conditions => 'users_count = 0'
  named_scope :ordered, :order => 'lower(name) ASC, created_at DESC'
  named_scope :with_type, lambda { |type| {:conditions => ["organizations.raw_type = ?", type]} }
  named_scope :reporting, :conditions => ['raw_type not in (?)', NON_REPORTING_TYPES]
  named_scope :nonreporting, :conditions => ['raw_type in (?)', NON_REPORTING_TYPES]
  named_scope :responses_by_states, lambda { |request, states|
    { :joins => {:data_responses => :data_request },
      :conditions => ["data_requests.id = ? AND
                       data_responses.state IN (?)", request.id, states]} }
  named_scope :sorted, { :order => "LOWER(organizations.name) ASC" }

  ### Class Methods

  def self.with_users
    find(:all, :joins => :users, :order => 'organizations.name ASC').uniq
  end

  def self.download_template(organizations = [])
    FasterCSV.generate do |csv|
      csv << Organization::FILE_UPLOAD_COLUMNS
      if organizations
        organizations.each do |org|
          row = [org.name, org.raw_type, org.fosaid, org.currency]
          csv << row
        end
      end
    end
  end

  def self.create_from_file(doc)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      organization = Organization.new(attributes)
      organization.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
  end

  ### Instance Methods

  # Convenience until we deprecate the "data_" prefixes
  def responses
    self.data_responses
  end

  def to_s
    name
  end

  # TODO -move to presenter
  def user_emails(limit = 3)
    self.users.find(:all, :limit => limit).map{|u| u.email}
  end

  # TODO -move to presenter
  def display_name(length = 100)
    n = self.name || "Unnamed organization"
    n.first(length)
  end

  # returns the last response that was created.
  def latest_response
    self.responses.latest_first.first
  end

  def reporting?
    !nonreporting?
  end

  def nonreporting?
    NON_REPORTING_TYPES.include?(raw_type)
  end

  def currency
    read_attribute(:currency).blank? ? "USD" : read_attribute(:currency)
  end

  # last login at will return nil on first login, but current will be set
  def current_user_logged_in
    users.select{ |a,b| a.current_login_at.present? }.max do |a,b|
      a.current_login_at <=> b.current_login_at
    end
  end

  protected

    def check_no_requests
      unless data_requests.count == 0
        errors.add_to_base "Cannot delete organization with Requests"
        return false
      end
    end

    def check_no_funder_references
      unless out_flows.empty?
        errors.add_to_base "Cannot delete organization with (external) Funder references"
        return false
      end
    end

    def check_no_implementer_references
      unless implementer_splits.empty?
        errors.add_to_base "Cannot delete organization with (external) Implementer references"
        return false
      end
    end

  private

    def validates_date_range
      errors.add(:base, "The end date must be exactly one year after the start date") unless (fiscal_year_start_date + (1.year - 1.day)).eql? fiscal_year_end_date
    end

    def create_data_responses
      unless NON_REPORTING_TYPES.include?(raw_type)
        DataRequest.all.each do |data_request|
          dr = self.data_responses.find(:first,
                    :conditions => {:data_request_id => data_request.id})
          unless dr
            dr = self.data_responses.new
            dr.data_request = data_request
            dr.save!
          end
        end
      end
    end
end


# == Schema Information
#
# Table name: organizations
#
#  id                               :integer         not null, primary key
#  name                             :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  raw_type                         :string(255)
#  fosaid                           :string(255)
#  users_count                      :integer         default(0)
#  currency                         :string(255)
#  fiscal_year_start_date           :date
#  fiscal_year_end_date             :date
#  contact_name                     :string(255)
#  contact_position                 :string(255)
#  contact_phone_number             :string(255)
#  contact_main_office_phone_number :string(255)
#  contact_office_location          :string(255)
#  location_id                      :integer
#  implementer_type                 :string(255)
#  funder_type                      :string(255)
#

