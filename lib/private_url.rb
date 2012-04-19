module PrivateUrl

  def private_url?
    RAILS_ENV == 'production' || RAILS_ENV == 'staging'
  end
end
