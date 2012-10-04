class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  acts_as_nested_set
end

Code.where("type IS NULL OR type = 'Code'").each do |code|
  code.type = 'Purpose'
  code.save!
end
