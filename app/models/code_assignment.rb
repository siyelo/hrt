class CodeAssignment < ActiveRecord::Base
  include CurrencyNumberHelper

  strip_commas_from_all_numbers

  ### Attributes
  attr_accessible :activity, :code, :percentage,
                  :sum_of_children, :cached_amount

  ### Associations
  belongs_to :activity
  belongs_to :code

  ### Validations
  validates_presence_of :activity_id, :code_id
  validates_inclusion_of :percentage, :in => 0..100,
    :if => Proc.new { |model| model.percentage.present? },
    :message => "must be between 0 and 100"

  ### Delegates
  delegate :data_response, :to => :activity
  delegate :currency, :to => :activity, :allow_nil => true

  ### Named scopes
  named_scope :with_code_id,
              lambda { |code_id| { :conditions =>
                ["code_assignments.code_id = ?", code_id]} }
  named_scope :with_code_ids,
              lambda { |code_ids| { :conditions =>
                ["code_assignments.code_id IN (?)", code_ids]} }
  named_scope :with_activity,
              lambda { |activity_id| { :conditions =>
                ["code_assignments.activity_id = ?", activity_id]} }
  named_scope :with_activities,
              lambda { |activity_ids|{ :conditions =>
                ["code_assignments.activity_id in (?)", activity_ids]} }
  named_scope :with_type,
              lambda { |type| { :conditions =>
                ["code_assignments.type = ?", type]} }
  named_scope :with_types,
              lambda { |types| { :conditions =>
                ["code_assignments.type IN (?)", types]} }
  named_scope :sorted, {
              :order => "code_assignments.cached_amount DESC" }
  named_scope :with_request,
              lambda { |request_id| {
                :joins =>
                  "INNER JOIN activities ON
                    activities.id = code_assignments.activity_id
                  INNER JOIN data_responses
                    ON activities.data_response_id = data_responses.id
                  INNER JOIN data_requests
                    ON data_responses.data_request_id = data_requests.id AND
                    data_responses.data_request_id = #{request_id}",
              }}

  ### Class Methods

  # TODO: needs to be moved to a service
  # particularly because its trying to be responsible
  # for updating the activity's _valid? cache fields with
  # update_classified_amount_cache()
  def self.update_classifications(activity, classifications)
    present_ids = []
    assignments = self.with_activity(activity.id)
    codes       = Code.find(classifications.keys)

    classifications.each_pair do |code_id, value|
      code = codes.detect{|code| code.id == code_id.to_i}

      if value.present?
        present_ids << code_id

        ca = assignments.detect{|ca| ca.code_id == code_id.to_i}

        # initialize new code assignment if it does not exist
        ca = self.new(:activity => activity, :code => code) unless ca
        ca.percentage = value
        ca.save
      end
    end

    # SQL deletion, faster than deleting records individually
    if present_ids.present?
      self.delete_all(["activity_id = ? AND code_id NOT IN (?)",
                                 activity.id, present_ids])
    else
      self.delete_all(["activity_id = ?", activity.id])
    end

    activity.update_classified_amount_cache(self)
  end

  def cached_amount
    self[:cached_amount] || 0
  end

  ### Instance Methods

  def percentage=(amount)
    amount.present? ? write_attribute(:percentage, amount.to_f.round_with_precision(2)) : write_attribute(:percentage, nil)
  end

  # Checks if it's a budget code assignment
  def budget?
    ['CodingBudget',
     'CodingBudgetCostCategorization',
     'CodingBudgetDistrict',
     'HsspBudget'].include?(type.to_s)
  end
end










# == Schema Information
#
# Table name: code_assignments
#
#  id              :integer         not null, primary key
#  activity_id     :integer         indexed => [code_id, type]
#  code_id         :integer         indexed => [activity_id, type], indexed
#  type            :string(255)     indexed => [activity_id, code_id]
#  percentage      :decimal(, )
#  cached_amount   :decimal(, )     default(0.0)
#  sum_of_children :decimal(, )     default(0.0)
#  created_at      :datetime
#  updated_at      :datetime
#

