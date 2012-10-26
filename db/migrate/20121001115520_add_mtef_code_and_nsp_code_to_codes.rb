Object.send(:remove_const, "Purpose") if defined?(Purpose)
Object.send(:remove_const, "Input") if defined?(Input)
Object.send(:remove_const, "Location") if defined?(Location)

class Code < ActiveRecord::Base
  extend CodeVersion
  extend TreeHelpers

  acts_as_nested_set
end

# define old STI models
class Mtef < Code; end
class Nsp  < Code; end
class Nasa < Code; end
class Nha  < Code; end
class HsspStratProg < Code; end
class HsspStratObj < Code; end
class Beneficiary < Code; end
class Input < Code; end
class Purpose < Code; end
class Location < Code; end

class AddMtefCodeAndNspCodeToCodes < ActiveRecord::Migration
  def change
    add_column :codes, :mtef_code, :string
    add_column :codes, :nsp_code, :string

    Mtef.reset_column_information
    Nsp.reset_column_information
    Nasa.reset_column_information
    Nha.reset_column_information

    Code.all.each do |purpose|
      codes = purpose.self_and_ancestors.reverse

      mtef = codes.detect { |a| a.type == "Mtef" && !a.root? }
      purpose.mtef_code = (mtef ? mtef.short_display : nil)

      nsp = codes.detect { |a| a.type == "Nsp" }
      purpose.nsp_code = (nsp ? nsp.short_display : nil)

      purpose.save!
    end
  end
end
