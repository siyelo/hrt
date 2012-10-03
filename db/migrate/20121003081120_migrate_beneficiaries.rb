class MigrateBeneficiaries < ActiveRecord::Migration
  def up
    load 'db/fixes/20121003_migrate_beneficiaries.rb'
  end

  def down
    puts 'irreversible migration'
  end
end
