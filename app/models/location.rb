class Location < ActiveRecord::Base
  extend CodeVersion

  ### Attributes
  attr_accessible :name

  ### Validations
  validates :name, :presence => true
  validates :version, :presence => true

  # Associations
  has_many :code_splits, as: :code, dependent: :destroy
  # has_many :activities, :through => :code_splits

  ### Scopes
  scope :national_level, { :conditions => "lower(locations.name) = 'national level'" }
  scope :without_national_level, { :conditions => "lower(locations.name) != 'national level'" }
  scope :sorted, { :order => "locations.name" }
end

