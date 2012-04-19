# Performance test/benchmarker for Reports
# Handy as a rake task insofar as you're not running
# db:create or db:migrate, in which case this rake task
# interferes  - uncomment to use
#
# require File.expand_path(File.join(File.dirname(__FILE__),'..','..','config','environment'))
# require 'benchmark'


# namespace :reports do
#   Report::REPORTS.each do |report|

#     desc "Run #{report} report"
#     task report.to_sym => :environment do |t|
#       request_id = ARGV[1] || DataRequest.sorted.last.id
#       request = DataRequest.find(request_id)
#       puts "  => Running #{report} for Request #{request.name} (id: #{request_id})"
#       r = Report.find_or_initialize_by_key_and_data_request_id report, request.id
#       Benchmark.bm do |x|
#         x.report("    ->") { r.generate_report }
#       end
#       puts "  => Done: #{report} - new id: #{r.id}\n\n"
#     end
#   end

#   desc "Run all reports"
#   task :all => Report::REPORTS
# end
