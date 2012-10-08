class LocationSplit < CodeSplit; end
class LocationBudgetSplit < LocationSplit; end
class LocationSpendSplit < LocationSplit; end

class InputSplit < CodeSplit; end
class InputBudgetSplit < InputSplit; end
class InputSpendSplit < InputSplit; end

class PurposeSplit < CodeSplit; end
class PurposeBudgetSplit < PurposeSplit; end
class PurposeSpendSplit < PurposeSplit; end

Location.reset_column_information
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

Code.update_all({:type => "OldLocation"}, {:type => "Location"})

class OldLocation < Code; end

Object.send(:remove_const, "Location") if defined?(Location)

class Location < ActiveRecord::Base
  extend CodeVersion

  ### Attributes
  attr_accessible :name

  ### Validations
  validates :name, :presence => true
  validates :version, :presence => true

  ### Scopes
  scope :national_level, { :conditions => "lower(locations.name) = 'national level'" }
  scope :without_national_level, { :conditions => "lower(locations.name) != 'national level'" }
  scope :sorted, { :order => "locations.name" }
end

OldLocation.transaction do
  old_locations = OldLocation.all

  old_locations.each do |old_location|
    location = Location.new
    location.name = old_location.short_display
    location.version = old_location.version

    location.save!

    old_location.code_splits.each do |code_split|
      code_split.code_id = location.id
      code_split.code_type = Location.to_s
      code_split.save!
    end

    old_location.destroy
  end
end
