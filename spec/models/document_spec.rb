require 'spec_helper'

describe Document do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:title) }
  end

  describe "Validations" do
    subject { Factory(:document) }
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }
    it { should have_attached_file(:document) }
    it { should validate_attachment_presence(:document) }
    it { should validate_attachment_size(:document).less_than(10.megabytes) }
  end
end
