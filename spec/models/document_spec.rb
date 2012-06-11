require 'spec_helper'

describe Document do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:document) }
    it { should allow_mass_assignment_of(:visibility) }
    it { should allow_mass_assignment_of(:description) }
  end

  describe "Validations" do
    subject { FactoryGirl.create(:document) }
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
    it { should_not validate_presence_of(:description) }
  end

  describe "Named Scopes" do
    before :each do
      @public_document = FactoryGirl.create :document, :visibility => 'public'
      @reporter_document = FactoryGirl.create :document, :visibility => 'reporters'
      @sysadmin_document = FactoryGirl.create :document, :visibility => 'sysadmins'
    end

    it 'returns public and reporter visible documents for reporter scope' do
      reporter_documents = Document.visible_to_reporters
      reporter_documents.size.should == 2
      reporter_documents.include?(@public_document).should be_true
      reporter_documents.include?(@reporter_document).should be_true
    end

    it 'returns only public documents for public scope' do
      public_documents = Document.visible_to_public
      public_documents.size.should == 1
      public_documents.include?(@public_document).should be_true
    end
  end

  describe "#private_document_url" do
    it "sets private url for production environment" do
      document = FactoryGirl.build(:document)
      document.stub(:private_url?).and_return(true)
      document.document.should_receive(:expiring_url)
      document.document.should_not_receive(:url)

      document.private_document_url
    end

    it "sets public url for other than production environment" do
      document = FactoryGirl.build(:document)
      document.stub(:private_url?).and_return(false)
      document.document.should_receive(:url)
      document.document.should_not_receive(:expiring_url)

      document.private_document_url
    end
  end
end
