class Reports::Detailed::ExportResponseStatus

  attr_accessor :builder

  def initialize(filetype)
    @responses = DataResponse.all.sort
    @builder = FileBuilder.new(filetype)
  end

  def data(&block)
    build_rows
    builder.data(&block)
  end

  private

  def build_rows
    builder.add_row(build_header)
    @responses.each do |response|
      builder.add_row(build_row(response))
    end
  end

  def build_header
    row = []
    row << 'Response ID'
    row << 'Response Name'
    row << 'Organization Name'
    row << 'State'
    row
  end

  def build_row(response)
    row = []
    row << response.id
    row << response.title
    row << response.organization.name
    row << response.state
    row
  end
end
