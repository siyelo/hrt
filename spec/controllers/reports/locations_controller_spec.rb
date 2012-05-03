require 'spec_helper'

describe Reports::LocationsController do
  context "as a visitor" do
    describe "it should be protected" do
      before :each do get :index, :id => 1 end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access this page") }
    end
  end
end