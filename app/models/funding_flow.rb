class FundingFlow < ActiveRecord::Base
  include AutocreateHelper

  ### Attributes
  attr_accessible :organization_text, :project_id, :from, :to,
                  :self_provider_flag, :organization_id_from,
                  :spend, :budget, :double_count, :_destroy

  ### Associations
  belongs_to :from, class_name: "Organization", foreign_key: "organization_id_from"
  belongs_to :project
  belongs_to :project_from, class_name: 'Project' # funder's project
  belongs_to :previous, class_name: 'FundingFlow'

  ### Validations
  # also see validations in BudgetSpendHelper
  #validates_presence_of :project_id # See: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2815-nested-models-build-should-directly-assign-the-parent
                                     # and workaround is in project.rb
  validates_numericality_of :spend, greater_than: 0,
    if: Proc.new { |ff| ff.spend.present? && (!ff.budget.present? || ff.budget == 0)  }
  validates_numericality_of :budget, greater_than: 0,
    if: Proc.new { |ff| ff.budget.present? && (!ff.spend.present? || ff.spend == 0) }
  validates_presence_of :organization_id_from
  # either budget or spend must be present
  validates_presence_of :spend, if: lambda {|ff| !ff.budget? && !ff.spend?},
    message: " and/or Planned must be present"

  # if project from id == nil => then the user hasnt linked them
  # if project from id == 0 => then the user can't find Funder project in a list
  # if project from id > 0 => user has selected a Funder project
  #
  validates_numericality_of :project_from_id, greater_than_or_equal_to: 0,
    unless: lambda {|fs| fs["project_from_id"].blank?}
  # if we pass "-1" then the user somehow selected "Add an Organization..."
  validates_numericality_of :organization_id_from, greater_than_or_equal_to: 0
  validates_uniqueness_of :organization_id_from, scope: :project_id,
    unless: Proc.new { |m| m.new_record? }

  ### Delegates
  delegate :organization, to: :project  #allowing nil as a workaround for nested object creation via project
  delegate :data_response, to: :project
  delegate :currency, to: :project, allow_nil: true

  ### Association aliases
  alias :response :data_response
  alias :to :organization

  ### Named Scopes
  scope :sorted, { joins: "LEFT OUTER JOIN organizations ON
    organizations.id = funding_flows.organization_id_from",
    order: "LOWER(organizations.name) ASC"}

  ### Instance Methods
  #
  def to_s
    "Project: #{project.name}; From: #{from.name}; To: #{to.name}"
  end

  def name
    self.to_s
  end

  def organization_id_from=(id_or_name)
    self.organization_id_from_will_change! # trigger saving of this model
    new_id = self.assign_or_create_organization(id_or_name)
    super(new_id)
  end

  def self_funded?
    from == to
  end

  def donor_funded?
    ["Donor",  "Multilateral", "Bilateral"].include?(from.raw_type)
  end

  def in_flow?
    self.organization == self.to
  end

  def out_flow?
    self.organization == self.from
  end

  def possible_double_count?
    data_request_id = project.data_response.data_request_id
    from_response = from.data_responses.with_request(data_request_id).first

    check_double_count(from_response) || false
  end

  def check_double_count(from_response)
    from && !self_funded? && from.reporting? &&
      from_response && from_response.accepted?
  end

  class << self
    def mark_double_counting(content)
      hash = {}
      rows = FileParser.parse(content, 'xls')

      rows.map do |row|
        double_count = row['Actual Funder Double-Count?']
        double_count = double_count.value if double_count.respond_to?(:value)
        double_count = case double_count.to_s.downcase
        when 'true'
          true
        when 'false'
          false
        else
          nil
        end

        hash[row['Funding Flow ID'].to_s] = double_count
      end

      FundingFlow.find(:all, conditions: ["id IN (?)", hash.keys]).each do |ff|
        ff.double_count = hash[ff.id.to_s]
        ff.save(validate: false)
      end
    end
    handle_asynchronously :mark_double_counting
  end

  ### validation helpers

  # potential candidate for removal if these
  # errors can all be caught on data entry
  def has_organization_and_amounts?
    organization_id_from && (spend || 0) + (budget || 0) > 0
  end
end

