class RenameOtherCode < ActiveRecord::Migration
  def up
    code = Code.find(1714)
    code.short_display = 'Other inputs' if code.short_display = 'Other'
    code.save!
  end

  def down
    code = Code.find(1714)
    code.short_display = 'Other'
    code.save!
  end
end
