unless ['test', 'cucumber'].include? Rails.env
  load 'currencies_load_script.rb'
end
