shared_examples_for "a protected endpoint" do
  it { should redirect_to(root_url) }
  it { should set_the_flash.to("You must be logged in to access that page") }
end

shared_examples_for "a protected admin endpoint" do
  it { should redirect_to(root_url) }
  it { should set_the_flash.to("You must be an administrator to access that page") }
end

def it_should_require_sysadmin_for(*actions)
  actions.each do |action|
    it "#{action} action should require sysadmin role" do
      get action, id: 1 # so routes work for those requiring id
      response.should redirect_to(root_url)
      # controller.should_not_receive(:index)
      # get action
    end
  end
end
