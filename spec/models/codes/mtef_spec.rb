require File.dirname(__FILE__) + '/../../spec_helper'

describe Mtef do
  describe "roots with level" do
    it "returns roots with level" do
      # first level
      mtef = FactoryGirl.create(:mtef_code, :short_display => 'mtef')

      # second level
      nha = FactoryGirl.create(:nha_code, :short_display => 'nha')
      nha.move_to_child_of(mtef)

      # third level
      nsp = FactoryGirl.create(:nsp_code, :short_display => 'nsp')
      nsp.move_to_child_of(nha)

      # forth level
      nasa = FactoryGirl.create(:nasa_code, :short_display => 'nasa')
      nasa.move_to_child_of(nsp)

      Mtef.roots_with_level.should == [[0, mtef.id], [1, nha.id], [2, nsp.id], [3, nasa.id]]
    end

    it "returns codes by level" do
    end
  end
end
