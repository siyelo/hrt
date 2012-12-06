HEROKU_APP = ENV.fetch('HEROKU_APP')
DB_PASSWORD = ENV.fetch('DB_PASSWORD')
DB_USER = ENV.fetch('DB_USER')
DB_DATABASE = ENV.fetch('DB_DATABASE')


class Logger
  def self.log(message)
    puts "### -> #{message} ###"
  end
end


class DBBackup

  class << self
    def set_new_backup
      capture_new_backup
      download_backup
      response_backup
      delete_backup
    end

    private
    def capture_new_backup
      puts
      Logger.log 'Capturing new backup'
      system 'heroku pgbackups:capture --expire --app hrtprod'
    end

    def download_backup
      Logger.log 'Downloading DB backup'
      system "curl -o latest.dump `heroku pgbackups:url --app #{HEROKU_APP}`"
    end

    def response_backup
      ENV['PGPASSWORD'] = DB_PASSWORD # set password
      system "pg_restore --verbose --clean --no-acl --no-owner --no-password -h localhost -U #{DB_USER} -d #{DB_DATABASE} latest.dump"
    end

    def delete_backup
      Logger.log 'Deleting DB backup file'
      system 'rm latest.dump'
    end
  end
end


class DQReport
  attr_accessor :data_request, :amount_type, :filetype

  def initialize(data_request, amount_type, filetype)
    @data_request = data_request
    @amount_type = amount_type
    @filetype = filetype
  end

  def run
    Logger.log("Generating #{amount_type} report in #{filetype} format")
    content = Reports::Detailed::DynamicQuery.new(data_request, amount_type, filetype).data

    File.open(file_path, "w:UTF-8") {|f| f.write(content.force_encoding('UTF-8'))}
    Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
      zipfile.add(file_name, folder + '/' + file_name)
    end
    File.delete(file_path)
  end

  def zip_file_path
    "#{folder}#{file_name}.zip"
  end

  private

  def folder
    "#{Rails.root}/tmp/"
  end

  def file_name
    @file_name ||= "#{key}_#{data_request.id}_#{get_date}.#{filetype}"
  end

  def file_path
    "#{folder}#{file_name}"
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

class Worker
  class << self
    def generate(data_request, amount_type, filetype)
      report = DQReport.new(data_request, amount_type, filetype)
      report.run
    end
  end
end


# Create backup, generate and upload report files.
DBBackup.set_new_backup
last_data_request = DataRequest.order('id ASC').last
Worker.generate(last_data_request, :budget, 'xml')
Worker.generate(last_data_request, :spend, 'xml')
