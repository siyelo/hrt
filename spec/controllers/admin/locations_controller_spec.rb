require 'spec_helper'

describe Admin::LocationsController do
  describe "user permissions" do
    before :each do
      login # login as reporter
    end

    it_should_require_sysadmin_for :index, :edit, :update
  end
end
