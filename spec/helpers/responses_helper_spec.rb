require 'spec_helper'

describe ResponsesHelper do
  describe '#response_title' do
    it "displays the response title as organization + response title" do
      organization = mock(:organization, :name => 'SiyelosFinest')
      response = mock(:response, :title => 'Sexy response 2011')
      response.should_receive(:organization).once.and_return(organization)
      helper.response_title(response).should == "SiyelosFinest: Sexy response 2011"
    end
  end
end
