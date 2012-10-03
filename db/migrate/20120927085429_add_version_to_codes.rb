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

class AddVersionToCodes < ActiveRecord::Migration

  def change
    add_column :codes, :version, :integer

    Code.reset_column_information
    Code.all.each do |code|
      code.version = 1
      code.save!
    end
  end
end
