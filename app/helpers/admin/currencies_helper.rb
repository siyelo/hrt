module Admin::CurrenciesHelper
  def format_date(date)
    date.strftime('%d %b %Y')
  end
end

