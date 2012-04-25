module Reports::LocationsHelper
  def location_spend_table(spend_names_and_amounts)
    table = ""
    spend_names_and_amounts.each do |name, amount|
      table += "<tr><td>#{name}</td><td>#{amount}</td><td></td></tr>"
    end
    table
  end
end
