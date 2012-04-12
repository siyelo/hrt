require 'spec_helper'

describe Admin::DocumentsController do
  describe "user permissions" do
    before :each do
      login # login as reporter
    end

    it_should_require_sysadmin_for :index, :show, :new, :create,
                                   :edit, :update, :destroy
  end
end
