 class ImplementerSplit < ActiveRecord::Base
  include AutocreateHelper

  belongs_to :activity
  belongs_to :organization # the implementer
  belongs_to :previous, class_name: 'ImplementerSplit'

  attr_accessible :activity, :activity_id, :organization_id, :budget, :spend,
    :organization_mask, :organization, :organization_temp_name

  attr_accessor :organization_temp_name

  ### Validations
  # this seems to be bypassed on activity update if you pass two of the same orgs
  validates_uniqueness_of :organization_id, scope: :activity_id,
    message: "must be unique", unless: Proc.new { |m| m.new_record? }
  validates_numericality_of :spend, greater_than: 0,
    if: Proc.new { |is| is.spend.present? && (!is.budget.present? ||
                                                 is.budget == 0) }
  validates_numericality_of :budget, greater_than: 0,
    if: Proc.new { |is| is.budget.present? && (!is.spend.present? ||
                                                  is.spend == 0) }
  validates_presence_of :spend, message: " and/or Budget must be present",
    if: lambda { |is| (!((is.budget || 0) > 0)) && (!((is.spend || 0) > 0)) }
  validate :validate_organization_presence

  ### Delegates
  delegate :name, to: :organization, prefix: true, allow_nil: true # organization_name

  ### Named Scopes
  scope :sorted, { joins: "LEFT OUTER JOIN organizations ON
    organizations.id = implementer_splits.organization_id",
    order: "LOWER(organizations.name) ASC, implementer_splits.id ASC"}

  ### Instance methods

  def organization_mask
    @organization_mask || organization_name
  end

  # used in activity report
  def name
    organization_name
  end

  def organization_mask=(the_organization_mask)
    self.organization_id_will_change! # trigger saving of this model
    self.organization_id = assign_or_create_organization(the_organization_mask)
    @organization_mask   = the_organization_mask
  end

  def budget=(amount)
    num = NumberHelper.is_number?(amount) ? amount.to_f.round(2) : amount
    write_attribute(:budget, num)
  end

  def spend=(amount)
    num = NumberHelper.is_number?(amount) ? amount.to_f.round(2) : amount
    write_attribute(:spend, num)
  end

  def self_implemented?
    activity.organization == organization
  end

  def possible_double_count?
    if organization # needed for old data request
      reporting_response = activity.data_response
      implementing_response = organization.data_responses.
        with_request(reporting_response.data_request_id).first
      check_double_count(implementing_response, reporting_response)
    else
      return false
    end
  end

  def check_double_count(implementing_response, reporting_response)
    reporting_org         = reporting_response.organization
    implementing_org      = organization

    implementing_org && implementing_org != reporting_org &&
      implementing_org.reporting? && implementing_response &&
      implementing_response.accepted?
  end

  class << self
    def mark_double_counting(content)
      hash = {}
      rows = FileParser.parse(content, 'xls')

      rows.map do |row|
        double_count = row['Actual Double-Count?']
        double_count = double_count.value if double_count.respond_to?(:value)
        double_count = case double_count.to_s.downcase
        when 'true'
          true
        when 'false'
          false
        else
          nil
        end

        hash[row['Implementer Split ID'].to_s] = double_count
      end

      ImplementerSplit.find(:all, conditions: ["id IN (?)", hash.keys]).each do |split|
        split.double_count = hash[split.id.to_s]
        split.save(validate: false)
      end
    end
    handle_asynchronously :mark_double_counting
  end

  private
    def validate_organization_presence
      if organization_mask.blank? && organization_id.blank?
        errors.add(:organization_mask, "can't be blank")
      end
    end
end

