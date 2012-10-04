class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  ### Constants
  PURPOSES            = %w[Purpose]
  INPUTS              = %w[Input]
  LOCATIONS           = %w[Location]
  BENEFICIARIES       = %w[Beneficiary]
  FILE_UPLOAD_COLUMNS = %w[short_display long_display description type
   external_id parent_short_display hssp2_stratprog_val hssp2_stratobj_val
   official_name sub_account nha_code nasa_code]

  ### Attributes
  attr_writer   :type_string
  attr_accessible :short_display, :long_display, :description, :official_name,
                  :hssp2_stratprog_val, :hssp2_stratobj_val, :sub_account,
                  :nasa_code, :nha_code, :type_string, :parent_id, :type,
                  :external_id

  ### Validations
  validates :short_display, presence: true

  ### Callbacks
  before_save :assign_type

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set

  ### Associations
  has_many :code_splits, :dependent => :destroy
  has_many :activities, :through => :code_splits

  ### Named scope
  scope :with_type,  lambda { |type| where(["codes.type = ?", type]) }
  scope :with_types, lambda { |types| where(["codes.type IN (?)", types]) }
  scope :with_version, lambda { |version| where(version: version) }
  scope :purposes, where(["codes.type in (?)", PURPOSES])

  def name
    short_display
  end

  def to_s
    short_display
  end

  def type_string
    @type_string || self[:type]
  end

  private

    # kiiillllll meeeeeeeee
    def assign_type
      self[:type] = type_string
    end
end

# == Schema Information
#
# Table name: codes
#
#  id                  :integer         not null, primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :datetime
#  updated_at          :datetime
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

