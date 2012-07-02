class Project < ActiveRecord::Base
  include ActsAsDateChecker
  include BudgetSpendHelper
  include Project::Validations
  include ResponseStateCallbacks

  MAX_NAME_LENGTH = 64

  strip_commas_from_all_numbers

  ### Associations
  belongs_to :data_response, counter_cache: true
  belongs_to :previous, class_name: 'Project'
  has_one :organization, through: :data_response
  has_many :activities, dependent: :destroy
  has_many :other_costs, dependent: :destroy
  has_many :normal_activities, class_name: "Activity",
           conditions: [ "activities.type IS NULL"], dependent: :destroy
  has_many :funding_flows, dependent: :destroy

  #FIXME - cant initialize nested in_flows because of the :conditions statement
  has_many :in_flows, class_name: "FundingFlow"
  has_many :out_flows, class_name: "FundingFlow",
           conditions: [ 'organization_id_from = #{organization.id}' ]
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :implementer_splits, through: :activities

  # Nested attributes
  accepts_nested_attributes_for :in_flows, allow_destroy: true,
    reject_if: Proc.new { |attrs| attrs['organization_id_from'].blank? }
  accepts_nested_attributes_for :activities, allow_destroy: true

  ### Callbacks
  # also check lib/response_state_callbacks
  before_validation :strip_leading_spaces
  before_validation :assign_project_to_in_flows
  before_validation :assign_project_to_activities
  before_validation :downcase_budget_type

  ### Validations
  validates_uniqueness_of :name, scope: :data_response_id
  validates_presence_of :name, :data_response_id, :currency
  validates_inclusion_of :budget_type, in: ["on", "off", "na"],
                         message: "is not selected"
  validates_inclusion_of :currency,
    in: Money::Currency::TABLE.map{|k, v| "#{k.to_s.upcase}"},
    allow_nil: true, unless: Proc.new {|p| p.currency.blank?}
  validates_presence_of :start_date, :end_date
  validates_date :start_date
  validates_date :end_date
  validates_length_of :name, within: 1..MAX_NAME_LENGTH
  validate :has_in_flows?, if: Proc.new {|model| model.in_flows.reject{ |attrs|
    attrs['organization_id_from'].blank? || attrs.marked_for_destruction? }.empty?}
  validate :validate_funder_uniqueness
  validate :validate_dates_order

  ### Attributes
  attr_accessible :name, :description, :data_response, :_destroy,
                  :data_response_id, :activities, :start_date,
                  :end_date, :currency, :budget_type,
                  :activities_attributes, :in_flows_attributes, :in_flows

  ### Delegates
  delegate :organization, to: :data_response, allow_nil: true #workaround for object creation

  ### Named Scopes
  scope :sorted, { order: "projects.name" }


  ### Instance methods
  def response
    data_response
  end

  def deep_clone
    clone = self.dup
    # has_many's with deep associations
    [:normal_activities, :other_costs].each do |assoc|
      clone.send(assoc) << self.send(assoc).map { |obj| obj.deep_clone }
    end

    clone.in_flows = self.in_flows.collect { |obj| obj.project_id = nil; obj.dup }

    clone
  end

  # potential candidate for removal if these
  # errors can all be caught on data entry
  def funding_sources_have_organizations_and_amounts?
    in_flows.all? { |ff| ff.has_organization_and_amounts? }
  end

  def locations
    activities.inject([]){ |acc, a| acc.concat(a.locations) }.uniq
  end

  def <=>(e)
    self.name <=> e.name
  end

  private

    def has_in_flows?
      errors.add(:base, "Project must have at least one Funding Source.")
    end

    def strip_leading_spaces
      self.name = self.name.strip if self.name
      self.description = self.description.strip if self.description
    end

    def downcase_budget_type
      self.budget_type = budget_type.to_s.downcase
    end

    # work arround for validates_presence_of :project issue
    # children relation can do only validation by :project, not :project_id
    # See: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2815-nested-models-build-should-directly-assign-the-parent
    def assign_project_to_in_flows
      in_flows.each {|ff| ff.project = self}
    end

    #assign project object so nested attributes for activities pass the project_id validation
    def assign_project_to_activities
      activities.each {|a| a.project = self}
    end

    def validate_funder_uniqueness
      funders = in_flows.select{|e| !e.marked_for_destruction? }.map(&:organization_id_from)
      if funders.length != funders.uniq.length
        errors.add(:base, "Duplicate Project Funding Sources")
      end
    end

    def validate_dates_order
      if start_date.present? && end_date.present? && start_date >= end_date
        errors.add(:start_date, "Start date must come before End date.")
      end
    end
end



# == Schema Information
#
# Table name: projects
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  description      :text
#  start_date       :date
#  end_date         :date
#  created_at       :datetime
#  updated_at       :datetime
#  currency         :string(255)
#  data_response_id :integer         indexed
#  budget_type      :string(255)
#

