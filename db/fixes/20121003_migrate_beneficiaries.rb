class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  acts_as_nested_set
end

Code.update_all({:type => "OldBeneficiary"}, {:type => "Beneficiary"})

class OldBeneficiary < Code
  has_and_belongs_to_many :activities, join_table: 'activities_beneficiaries', foreign_key: 'beneficiary_id' # organizations targeted by this activity / aided
end

Object.send(:remove_const, "Beneficiary") if defined?(Beneficiary)
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

Beneficiary.reset_column_information

OldBeneficiary.transaction do
  old_beneficiaries = OldBeneficiary.includes(:activities).all
  ActiveRecord::Base.connection.execute "DELETE FROM activities_beneficiaries"

  old_beneficiaries.each do |old_beneficiary|
    beneficiary = Beneficiary.new
    beneficiary.name = old_beneficiary.short_display
    beneficiary.version = old_beneficiary.version

    beneficiary.save!

    beneficiary.activities << old_beneficiary.activities
    old_beneficiary.destroy
  end
end
