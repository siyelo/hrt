# Capture new backup:
# heroku pgbackups:capture --expire --app hrtprod
#
# Download backup:
# curl -o latest.dump `heroku pgbackups:url --app hrtprod`
#
# Restore backup:
# pg_restore --verbose --clean --no-acl --no-owner -h localhost -U hrt_dev -d hrt_dev latest.dump
#
# Run this report
# rails runner script/reports/dqr.rb budget xml
# rails runner script/reports/dqr.rb spend xml

class DQReport
  attr_accessor :data_request, :amount_type, :filetype

  def initialize(data_request, amount_type, filetype)
    @data_request = data_request
    @amount_type = amount_type
    @filetype = filetype
  end

  def run
    content = Reports::Detailed::DynamicQuery.new(data_request, amount_type, filetype).data

    File.open(file_path, "w:UTF-8") {|f| f.write(content.force_encoding('UTF-8'))}
    Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
      zipfile.add(file_name, folder + '/' + file_name)
    end
    File.delete(file_path)
  end

  private

  def folder
    "#{Rails.root}/tmp/"
  end

  def file_name
    "#{key}_#{data_request.id}_#{get_date}.#{filetype}"
  end

  def zip_file_path
    "#{folder}#{file_name}.zip"
  end

  def file_path
    folder + file_name
  end

  def report_name
    "dynamic_query"
  end

  def key
    "#{amount_type}_#{report_name}"
  end

  def get_date
    `date '+%Y-%m-%d-%H%Mhrs'`.chomp
  end
end


last_data_request = DataRequest.order('id ASC').last
amount_type = ARGV[0].to_sym
filetype = ARGV[1]


report = DQReport.new(last_data_request, amount_type, filetype)
report.run
