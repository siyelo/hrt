class ProjectCurrencyDataFix < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20120516082215_project_currency_data_fix.rb'
  end

  def self.down
    puts 'IRREVERSIBLE MIGRATION'
  end
end
