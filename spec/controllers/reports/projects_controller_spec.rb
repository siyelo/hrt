require 'spec_helper'

describe Reports::ProjectsController do
  context "as a visitor" do
    describe "it should be protected" do
      before :each do get :show, :id => 1 end
      it { should redirect_to(root_url) }
      it { should set_the_flash.to("You must be logged in to access this page") }
    end
  end
end
