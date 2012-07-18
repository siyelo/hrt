# Airbrake.configure do |config|
#   config.api_key = '34b3b393692b5ea183ab2916fc7acd67'
# end

Airbrake.configure do |config|
  config.api_key		 	= ENV['AIRBRAKE_KEY']
  config.host				= 'errbit.siyelo.com'
  config.port				= 80
  config.secure			        = config.port == 443
end
