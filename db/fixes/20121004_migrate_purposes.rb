Purpose.reset_column_information
CodeSplit.reset_column_information
InputSplit.reset_column_information
LocationSplit.reset_column_information
PurposeSplit.reset_column_information
InputBudgetSplit.reset_column_information
InputSpendSplit.reset_column_information
LocationBudgetSplit.reset_column_information
LocationSpendSplit.reset_column_information
PurposeBudgetSplit.reset_column_information
PurposeSpendSplit.reset_column_information

class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  has_many :code_splits

  acts_as_nested_set
end

Code.update_all({:type => "OldPurpose"}, {:type => "Purpose"})

class OldPurpose < Code;
end

Object.send(:remove_const, "Purpose") if defined?(Purpose)

class Purpose < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  ### Attributes
  attr_accessible :name, :description, :official_name, :sub_account,
    :hssp2_stratobj_val, :hssp2_stratprog_val, :mtef_code, :nasa_code,
    :nha_code, :nsp_code

  ### Validations
  validates :name, :presence => true
  validates :version, :presence => true

  ### Associations
  has_many :code_splits, as: :code, dependent: :destroy

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set
end

def migrate_purpose(old_purpose, parent)
  purpose = Purpose.new
  purpose.name = old_purpose.short_display
  purpose.description = old_purpose.description
  purpose.version = old_purpose.version
  purpose.official_name = old_purpose.official_name
  purpose.sub_account = old_purpose.sub_account
  purpose.mtef_code = old_purpose.mtef_code
  purpose.nsp_code = old_purpose.nsp_code
  purpose.nasa_code = old_purpose.nasa_code
  purpose.nha_code = old_purpose.nha_code
  purpose.hssp2_stratprog_val = old_purpose.hssp2_stratprog_val
  purpose.hssp2_stratobj_val = old_purpose.hssp2_stratobj_val
  purpose.parent = parent

  purpose.save!

  old_purpose.code_splits.each do |code_split|
    code_split.code_id = purpose.id
    code_split.code_type = Purpose.to_s
    code_split.save!
  end

  return purpose
end

def migrate_purposes(old_purposes, parent)
  old_purposes.each do |old_purpose|
    new_parent = migrate_purpose(old_purpose, parent)
    migrate_purposes(old_purpose.children, new_parent) if old_purpose.children.present?
  end
end

OldPurpose.transaction do
  migrate_purposes(OldPurpose.roots, nil)
  OldPurpose.delete_all
end
