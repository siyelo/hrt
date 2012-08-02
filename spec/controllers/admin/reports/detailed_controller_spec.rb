require 'spec_helper'

describe Admin::Reports::DetailedController do

  include ActionDispatch::TestProcess

  before :each do
    login_as_admin
  end

  describe "#mark_double_counts" do
    context "file is blank" do
      it "sets flash error" do
        put :mark_double_counts, :file => nil
        flash[:error].should == "Please select a file to upload"
      end
    end

    context "file is correct" do
      it "sets flash notice - Activity Overview" do
        file = fixture_file_upload('/activity_overview.xls',
                                   "application/vnd.ms-excel")
        ImplementerSplit.should_receive(:mark_double_counting).and_return(true)
        put :mark_double_counts, file: file, report: 'activity_overview'
        flash[:notice].should == "Your file is being processed, please reload this page in a couple of minutes to see the results"
      end

      it "sets flash notice - Funding Source" do
        file = fixture_file_upload('/activity_overview.xls',
                                   "application/vnd.ms-excel")
        FundingFlow.should_receive(:mark_double_counting).and_return(true)
        put :mark_double_counts, file: file, report: 'funding_source'
        flash[:notice].should == "Your file is being processed, please reload this page in a couple of minutes to see the results"
      end
    end

    context "valid format" do
      it "accepts xls format" do
        file = fixture_file_upload('/activity_overview.xls',
                                   "application/vnd.ms-excel")
        ImplementerSplit.should_receive(:mark_double_counting).and_return(true)
        put :mark_double_counts, file: file, report: 'activity_overview'
        flash[:notice].should == "Your file is being processed, please reload this page in a couple of minutes to see the results"
      end

      it "accepts zip format" do
        file = fixture_file_upload('/activity_overview.zip', "application/zip")
        ImplementerSplit.should_receive(:mark_double_counting).and_return(true)
        put :mark_double_counts, file: file, report: 'activity_overview'
        flash[:notice].should == "Your file is being processed, please reload this page in a couple of minutes to see the results"
      end
    end

    context "invalid format" do
      it "does not accept pdf format" do
        file = fixture_file_upload('/activity_overview.pdf', "application/pdf")
        put :mark_double_counts, file: file, report: 'activity_overview'
        flash[:error].should == "Invalid file format. Please select .xls or .zip format."
      end
    end
  end

  describe "#generate" do
    it "generates report without delay" do
      report = FactoryGirl.create(:report, :key => 'activity_overview',
                                  :data_request => @data_request)
      Report.stub(:find_or_initialize_by_key_and_data_request_id).and_return(report)

      get :generate, :id => 'activity_overview'
      response.should be_redirect
      flash[:notice].should == "We are generating your report and will send you an email (at #{@admin.email}) when it is ready."

      unread_emails_for(@admin.email).size.should == 1
      open_email(@admin.email).body.should include(
        'We have generated the report for you')
    end
  end
end
