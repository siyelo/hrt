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
  # has_many :activities, :through => :code_splits

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set
end
