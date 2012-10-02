class Beneficiary < ActiveRecord::Base
  extend CodeVersion

  ### Attributes
  attr_accessible :name

  ### Validations
  validates :name, presence: true
  validates :version, presence: true

  ### Associations
  has_and_belongs_to_many :activities # organizations targeted by this activity / aided

end
