require 'spec_helper'

describe Users::SessionsController do

  before :each do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it "redirects to root path" do
    get :new
    response.should redirect_to(root_path)
  end
end
