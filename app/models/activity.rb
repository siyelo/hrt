class Activity < ActiveRecord::Base
  include CurrencyNumberHelper
  include Activity::Classification
  include AutocreateHelper
  include BudgetSpendHelper

  ### Constants
  MAX_NAME_LENGTH = 64

  ### ClassLevel Method Invocations
  strip_commas_from_all_numbers

  ### Attribute Protection
  attr_accessible :project_id, :name, :description,
    :beneficiary_ids, :other_beneficiaries, :implementer_splits_attributes,
    :organization_ids, :targets_attributes, :outputs_attributes,
    :user_id, :data_response_id, :planned_for_gor_q1,
    :planned_for_gor_q2, :planned_for_gor_q3, :planned_for_gor_q4

  ### Associations
  belongs_to :data_response
  belongs_to :project
  belongs_to :user
  belongs_to :previous, class_name: 'Activity'
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity
  has_many :implementer_splits, dependent: :delete_all
  has_many :implementers, through: :implementer_splits, source: :organization
  has_many :code_splits, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :targets, dependent: :destroy
  has_many :outputs, dependent: :destroy

  has_many :leaf_budget_purposes,
    class_name: 'CodeSplit', conditions: ["code_splits.code_type = 'Purpose' AND
      code_splits.spend IS FALSE AND code_splits.sum_of_children = 0"]
  has_many :leaf_spend_purposes,
    class_name: 'CodeSplit', conditions: ["code_splits.code_type = 'Purpose' AND
      code_splits.spend IS TRUE AND code_splits.sum_of_children = 0"]
  has_many :leaf_budget_inputs,
    class_name: 'CodeSplit', conditions: ["code_splits.code_type = 'Input' AND
      code_splits.spend IS FALSE AND code_splits.sum_of_children = 0"]
  has_many :leaf_spend_inputs,
    class_name: 'CodeSplit', conditions: ["code_splits.code_type = 'Input' AND
      code_splits.spend IS TRUE AND code_splits.sum_of_children = 0"]
  has_many :location_budget_splits,
    class_name: 'CodeSplit', conditions: ["code_splits.code_type = 'Location' AND
      code_splits.spend IS FALSE AND code_splits.sum_of_children = 0"]
  has_many :location_spend_splits,
    class_name: 'CodeSplit', conditions: ["code_splits.code_type = 'Location' AND
      code_splits.spend IS TRUE AND code_splits.sum_of_children = 0"]

  ### Nested attributes
  accepts_nested_attributes_for :implementer_splits, allow_destroy: true,
    reject_if: Proc.new { |attrs| attrs['organization_mask'].blank? }
  accepts_nested_attributes_for :targets, allow_destroy: true,
    reject_if: Proc.new { |attrs| attrs['description'].blank? }
  accepts_nested_attributes_for :outputs, allow_destroy: true,
    reject_if: Proc.new { |attrs| attrs['description'].blank? }

  ### Callbacks
  before_validation :strip_input_fields
  after_destroy     :restart_response_if_all_activities_removed
  before_update     :update_all_classified_amount_caches

  ### Delegates
  delegate :currency, to: :project, allow_nil: true
  delegate :data_request, to: :data_response
  delegate :organization, to: :data_response

  ### Validations
  # also see validations in BudgetSpendHelper
  validate :validate_implementers_uniqueness
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :project_id, if: :is_activity?,
    unless: Proc.new{ |a| a.project && a.project.new_record? }
  validates_presence_of :data_response_id
  validates_length_of :name, within: 3..MAX_NAME_LENGTH

  ### Scopes
  scope :roots,                { conditions: "activities.type IS NULL" }
  scope :greatest_first,       { order: "activities.budget DESC" }
  scope :with_type,         lambda { |type| {conditions:
                                             ["activities.type = ?", type]} }
  scope :with_request, lambda {|request| {
              select: 'DISTINCT activities.*',
              joins: 'INNER JOIN data_responses ON
                         data_responses.id = activities.data_response_id',
              conditions: ['data_responses.data_request_id = ?', request.id]}}
  scope :without_a_project,    { conditions: "project_id IS NULL" }
  scope :with_organization,    { joins: "INNER JOIN data_responses
                                    ON data_responses.id = activities.data_response_id
                                    INNER JOIN organizations
                                    ON data_responses.organization_id = organizations.id" }
  scope :sorted,               { order: "activities.name ASC" }

  ### Class Methods

  def self.unclassified
    self.find(:all).select {|a| !a.classified?}
  end

  ### Instance Methods

  # shortcut alias
  def response
    self.data_response
  end

  def update_attributes(params)
    update_classifications_from_params(params)
    super(params)
  end

  def to_s
    name
  end

  # TODO move to presenter
  def human_name
    "Activity"
  end

  def organization_name
    organization.name
  end

  # asynchronously update classification tree cached amounts
  def update_classified_amount_cache(code_type_key, amount_type)
    # disable update_all_classified_amount_caches
    # callback to be run again on save !!
    Activity.skip_callback(:update, :before, :update_all_classified_amount_caches)
    set_classified_amount_cache(code_type_key, amount_type)
    self.save(validate: false)
  end
  handle_asynchronously :update_classified_amount_cache

  #TODO  it should not be the responsibility of the activity to do this
  #  call it from the update classification API instead.
  #
  # Updates classified amount caches if budget or spend have been changed
  def update_all_classified_amount_caches
    [:purpose, :location, :input].each do |code_type_key|
      [:budget, :spend].each do |amount_type|
        update_classified_amount_cache(code_type_key, amount_type)
      end
    end
  end

  def deep_clone
    clone = self.dup
    %w[beneficiaries].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc))
    end
    # hasmany's
    %w[code_splits implementer_splits targets].each do |assoc|
      clone.send("#{assoc}=", self.send(assoc).collect { |obj| obj.dup })
    end
    clone
  end

  def classification_amount(classification_type)
    case classification_type.to_s
    when 'PurposeBudgetSplit', 'LocationBudgetSplit', 'InputBudgetSplit'
      total_budget
    when 'PurposeSpendSplit', 'LocationSpendSplit', 'InputSpendSplit'
      total_spend
    else
      raise "Invalid coding_klass #{classification_type}".to_yaml
    end
  end

  def implementer_splits_each_have_defined_districts?(coding_type)
    !implementer_split_district_code_splits(coding_type).empty?
  end

  def locations
    code_splits.locations.includes(:code).map { |ca| ca.code }.uniq
  end

  def implementer_splits_total(amount_method)
    smart_sum(implementer_splits, amount_method)
  end

  def implementer_splits_valid?
    valid = true
    self.implementer_splits.each do |is|
      if !is.valid?
        valid = false
        break
      end
    end
    valid
  end

  def purpose_spend_splits_valid?
    CodingTree.new(self, :purpose, :spend).valid?
  end

  def purpose_budget_splits_valid?
    CodingTree.new(self, :purpose, :budget).valid?
  end

  def input_spend_splits_valid?
    CodingTree.new(self, :input, :spend).valid?
  end

  def input_budget_splits_valid?
    CodingTree.new(self, :input, :budget).valid?
  end

  def location_spend_splits_valid?
    CodingTree.new(self, :location, :spend).valid?
  end

  def location_budget_splits_valid?
    CodingTree.new(self, :location, :budget).valid?
  end

  protected
  # intercept the classifications and process using the bulk classification update API
  # FIXME: the CodingBlah class method saves the activity in the middle of this update... Not good.
  def update_classifications_from_params(params)
    if params[:classifications].present?
      code_type_key = params[:classifications].keys.first.to_sym

      unless [:purpose, :input, :location].include?(code_type_key)
        raise "Invalid code type key"
      end

      classifications = params[:classifications][code_type_key]

      classifier = Classifier.new(self, code_type_key, :budget)
      classifier.update_classifications(classifications[:budget])

      classifier = Classifier.new(self, code_type_key, :spend)
      classifier.update_classifications(classifications[:spend])

      params.delete(:classifications)
    end
  end

  private
  #TODO  it should not be the responsibility of the activity to do this
  def set_classified_amount_cache(code_type_key, amount_type)
    coding_tree = CodingTree.new(self, code_type_key, amount_type)
    coding_tree.set_cached_amounts!
  end

  def is_activity?
    self.class.eql?(Activity)
  end

  def strip_input_fields
    self.name = self.name.strip if self.name
    self.description = self.description.strip if self.description
  end

  def get_valid_attribute_name(type)
    case type.to_s
    when 'PurposeBudgetSplit' then :purpose_budget_splits_valid
    when 'InputBudgetSplit' then :input_budget_splits_valid
    when 'LocationBudgetSplit' then :location_budget_splits_valid
    when 'PurposeSpendSplit' then :purpose_spend_splits_valid
    when 'InputSpendSplit' then :input_spend_splits_valid
    when 'LocationSpendSplit' then :location_spend_splits_valid
    else raise "Unknown type #{type}".to_yaml
    end
  end

  def restart_response_if_all_activities_removed
    # use .length since .empty? uses counter cache that isnt updated yet.
    if response && self.response.activities.length == 0
      response.state = 'started'
      response.save!
    end
  end

  def validate_implementers_uniqueness
    implementer_orgs = implementer_splits.select do |e|
      !e.marked_for_destruction?
    end.map(&:organization_id)

    if implementer_orgs.length != implementer_orgs.uniq.length
      # Reject splits where Org Id appears once & find unique ID of duplicates
      dup_ids = implementer_orgs.reject {|org_id| implementer_orgs.one? { |id| id == org_id } }
      # Find implmenter splits with an organization that has been duplicated
      duplicates = implementer_splits.select { |is| dup_ids.include?(is.organization_id) }
      self.errors.add(:base, "Duplicate Implementers")
      duplicates.each do |dup|
        dup.errors.add(:base, "Duplicate Implementer")
      end
    end
  end
end


# == Schema Information
#
# Table name: activities
#
#  id                  :integer         not null, primary key
#  name                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  description         :text
#  type                :string(255)     indexed
#  other_beneficiaries :text
#  data_response_id    :integer         indexed
#  activity_id         :integer         indexed
#  project_id          :integer
#  user_id             :integer
#  planned_for_gor_q1  :boolean
#  planned_for_gor_q2  :boolean
#  planned_for_gor_q3  :boolean
#  planned_for_gor_q4  :boolean
#

