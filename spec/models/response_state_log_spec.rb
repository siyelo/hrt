require 'spec_helper'

describe ResponseStateLog do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:data_response) }
  end
end
