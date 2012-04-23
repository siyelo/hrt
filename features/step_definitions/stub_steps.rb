Given /^I disable delayed job for data request$/ do
  DataRequest.should_receive(:handle_asynchronously)
end
