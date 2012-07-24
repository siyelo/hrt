class RenameOtherCode < ActiveRecord::Migration
  def up
    code = Code.find_by_id(1714)
    if code
      code.short_display = 'Other inputs' if code.short_display = 'Other'
      code.save!
    end
  end

  def down
    code = Code.find_by_id(1714)
    if code
      code.short_display = 'Other'
      code.save!
    end
  end
end
