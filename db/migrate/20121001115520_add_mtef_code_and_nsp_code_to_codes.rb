# define old STI models
class Mtef < Code; end
class Nsp  < Code; end
class Nasa < Code; end
class Nha  < Code; end
class HsspStratProg < Code; end
class HsspStratObj < Code; end

class AddMtefCodeAndNspCodeToCodes < ActiveRecord::Migration
  def change
    add_column :codes, :mtef_code, :string
    add_column :codes, :nsp_code, :string

    Mtef.reset_column_information
    Nsp.reset_column_information
    Code.where(["codes.type IN (?)", %w[Mtef Nsp Nasa Nha]]).each do |purpose|
      print "#{purpose.id} "
      codes = purpose.ancestors

      mtef = codes.detect { |a| a.type == "Mtef" && !a.root? }
      purpose.mtef_code = (mtef ? mtef.short_display : nil)

      nsp = codes.detect { |a| a.type == "Nsp" }
      purpose.nsp_code = (nsp ? nsp.short_display : nil)

      purpose.save!
    end
  end
end
