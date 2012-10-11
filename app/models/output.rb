class Output < ActiveRecord::Base
  ### Associations
  belongs_to :activity

  ### Validations
  validates_presence_of :description
  validates_length_of :description, :maximum => 250
end
