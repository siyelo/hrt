module PrivateUrl

  def private_url?
    Rails.env == 'production' || Rails.env == 'staging'
  end
end
