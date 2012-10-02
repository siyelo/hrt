class CreateBeneficiaries < ActiveRecord::Migration
  def change
    create_table :beneficiaries do |t|
      t.string :name
      t.integer :version
      t.timestamps
    end

    Code.where(['raw_type = ?', 'Beneficiary']).each do |code|
      beneficiary = Beneficiary.new
      beneficiary.name = code.short_display
      beneficiary.version = code.version

      beneficiary.save!
    end
  end
end
