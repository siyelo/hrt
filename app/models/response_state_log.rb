class ResponseStateLog < ActiveRecord::Base
  ### Associations
  belongs_to :user
  belongs_to :data_response
end
