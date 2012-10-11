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
  scope :budget, where(spend: false)
  scope :spend, where(spend: true)
  scope :leaf, where(sum_of_children: 0)

  scope :with_activity,
    lambda { |activity_id| where(["code_splits.activity_id = ?", activity_id]) }
  scope :with_activities,
    lambda { |activity_ids|
      where(["code_splits.activity_id in (?)", activity_ids]) }
  scope :with_codes, lambda { |codes| where(code_id: codes.map(&:id)) }
  scope :sorted, order("code_splits.cached_amount DESC")
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
          spend: is_spend?(amount_type))
  end

  def self.with_amount_type(amount_type)
    where(spend: is_spend?(amount_type))
  end

  def self.with_code_type(code_type)
    where(code_type: code_type)
  end

  def cached_amount
    self[:cached_amount] || 0
  end

  ### Instance Methods

  def percentage=(amount)
    amount.present? ? write_attribute(:percentage, amount.to_f.round(2)) : write_attribute(:percentage, nil)
  end

  def budget?
    !spend?
  end
end

