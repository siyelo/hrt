class CodeSplit < ActiveRecord::Base
  include CurrencyNumberHelper
  include AmountType
  extend AmountType

  strip_commas_from_all_numbers

  ### Attributes
  attr_accessible :activity, :code, :percentage,
                  :sum_of_children, :cached_amount

  ### Associations
  belongs_to :activity
  belongs_to :code, polymorphic: true

  ### Validations
  validates_presence_of :activity_id, :code_id
  validates_inclusion_of :percentage, :in => 0..100,
    :if => Proc.new { |model| model.percentage.present? },
    :message => "must be between 0 and 100"

  ### Delegates
  delegate :data_response, :to => :activity
  delegate :currency, :to => :activity, :allow_nil => true
  delegate :name, :to => :code, :allow_nil => true


  # TODO: rewrite scopes as methods and extract it into separate module
  # TODO: remove unused scopes
  ### Named scopes
  scope :purposes, where(code_type: Purpose.to_s)
  scope :inputs, where(code_type: Input.to_s)
  scope :locations, where(code_type: Location.to_s)
  scope :budget, where(is_spend: false)
  scope :spend, where(is_spend: true)
  scope :with_activity,
              lambda { |activity_id| { :conditions =>
                ["code_splits.activity_id = ?", activity_id]} }
  scope :with_activities,
              lambda { |activity_ids|{ :conditions =>
                ["code_splits.activity_id in (?)", activity_ids]} }
  scope :with_type,
              lambda { |type| { :conditions =>
                ["code_splits.type = ?", type]} }
  scope :with_types,
              lambda { |types| { :conditions =>
                ["code_splits.type IN (?)", types]} }
  scope :sorted, {
              :order => "code_splits.cached_amount DESC" }
  scope :with_request,
              lambda { |request_id| {
                :joins =>
                  "INNER JOIN activities ON
                    activities.id = code_splits.activity_id
                  INNER JOIN data_responses
                    ON activities.data_response_id = data_responses.id
                  INNER JOIN data_requests
                    ON data_responses.data_request_id = data_requests.id AND
                    data_responses.data_request_id = #{request_id}",
              }}


  ### Class Methods

  def self.with_code_and_type(code, amount_type)
    where(code_id: code.id, code_type: code.class,
          is_spend: is_spend?(amount_type))
  end

  def self.with_amount_type(amount_type)
    where(is_spend: is_spend?(amount_type))
  end

  def self.with_code_type(code_type)
    where(code_type: code_type)
  end
  # TODO: needs to be moved to a service
  # particularly because its trying to be responsible
  # for updating the activity's _valid? cache fields with
  # update_classified_amount_cache()
  def self.update_classifications(activity,  classifications, code_klass, amount_type)
    present_ids = []
    assignments = with_activity(activity.id)
    codes       = code_klass.find(classifications.keys)
    code_type   = code_klass.to_s.downcase

    classifications.each_pair do |code_id, value|
      code = codes.detect{|code| code.id == code_id.to_i}

      if value.present?
        present_ids << code_id

        # TODO: extract into method
        ca = assignments.detect do |ca|
          ca.code_id == code_id.to_i &&
          ca.code_type == code_type &&
          ca.is_spend == is_spend?(amount_type)
        end

        # initialize new code assignment if it does not exist
        ca ||= new(activity: activity, code: code)

        ca.is_spend = is_spend?(amount_type)
        ca.percentage = value
        ca.save
      end
    end

    # SQL deletion, faster than deleting records individually
    if present_ids.present?
      delete_all(["activity_id = ? AND code_type = ? AND code_id NOT IN (?)",
                   activity.id, code_type, present_ids])
    else
      delete_all(["activity_id = ? AND code_type = ?",
                  activity.id, code_type])
    end

    activity.update_classified_amount_cache(code_type, amount_type)
  end

  def cached_amount
    self[:cached_amount] || 0
  end

  ### Instance Methods

  def percentage=(amount)
    amount.present? ? write_attribute(:percentage, amount.to_f.round(2)) : write_attribute(:percentage, nil)
  end

  # Checks if it's a budget code assignment
  def budget?
    ['PurposeBudgetSplit',
     'InputBudgetSplit',
     'LocationBudgetSplit'].include?(type.to_s)
  end
end


# == Schema Information
#
# Table name: code_splits
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

