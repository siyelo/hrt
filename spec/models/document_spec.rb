require 'spec_helper'

describe Document do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:document) }
    it { should allow_mass_assignment_of(:visibility) }
  end

  describe "Validations" do
    subject { Factory(:document) }
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title) }
    it { should have_attached_file(:document) }
    it { should validate_attachment_presence(:document) }
    it { should validate_attachment_size(:document).less_than(10.megabytes) }
    it "should allow valid values for visibility" do
      Document::VISIBILITY_OPTIONS.each do |v|
        should allow_value(v).for(:visibility)
      end
    end
    it { should_not allow_value("other").for(:visibility) }
  end
end
