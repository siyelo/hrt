class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  has_many :code_splits, as: :code, dependent: :destroy

  acts_as_nested_set
end

Code.update_all({:type => "OldInput"}, {:type => "Input"})

class OldInput < Code;
end

Object.send(:remove_const, "Input") if defined?(Input)

class Input < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  ### Attributes
  attr_accessible :name, :description

  ### Validations
  validates :name, :presence => true
  validates :version, :presence => true

  # Associations
  has_many :code_splits, as: :code, dependent: :destroy

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set
end

Input.reset_column_information

def migrate_input(old_input, parent)
  input = Input.new
  input.name = old_input.short_display
  input.description = old_input.description
  input.version = old_input.version
  input.parent = parent

  input.save!

  old_input.code_splits.each do |code_split|
    code_split.code_id = input.id
    code_split.code_type = Input.to_s
    code_split.save!
  end

  return input
end

def migrate_inputs(old_inputs, parent)
  old_inputs.each do |old_input|
    new_parent = migrate_input(old_input, parent)
    migrate_inputs(old_input.children, new_parent) if old_input.children.present?
  end
end

OldInput.transaction do
  migrate_inputs(OldInput.roots, nil)
  OldInput.delete_all
end
