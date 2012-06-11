class ShortenDataRequestName < ActiveRecord::Migration
  def self.up
    d = DataRequest.first
    if d
      d.title = "FY2010 Workplan and FY2009 Expenditures"
      d.save(validate: false)
    end
  end

  def self.down
    d = DataRequest.first
    if d
      d.title = "FY2010 Workplan and FY2009 Expenditures - due date September 1"
      d.save(validate: false)
    end
  end
end
