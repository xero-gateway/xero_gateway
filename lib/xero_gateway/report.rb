module XeroGateway
  class Report
    include Money
    include Dates

    attr_reader :errors
    attr_accessor :report_id, :report_name, :report_type, :report_titles, :report_date, :updated_at, :body

    def initialize(params={})
      @errors       ||= []
      @body         ||= []

      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def self.from_xml(report_element)
      report = Report.new
      report_element.children.each do | element |
        case element.name
          when 'ReportID'         then report.report_id = element.text
          when 'ReportName'       then report.report_name = element.text
          when 'ReportType'       then report.report_type = element.text
          when 'ReportTitles'     then report.report_titles = "TODO" # <----------- TODO! Array of titles
          when 'ReportDate'       then report.report_date = element.text
          when 'UpdatedDateUTC'   then report.updated_at = parse_date_time(element.text)
          when 'Rows'
            each_row_content(element) do |content_hash|
              report.body << XeroGateway::Content.new(content_hash)
            end
          # todo: handle case "Fields"
        end
      end
      report
    end

  private

    def self.each_row_content(element, &block)
      columns  = find_body_column_names(element).map!{ |t| t.parameterize.underscore }
      xml_body = REXML::XPath.first(element, "//RowType[text()='Section']").parent
      xml_body.elements.each("Rows/Row") do |xml_cells|
        values = find_body_row_values(xml_cells)
        row_content = Hash[columns.zip values]
        yield row_content if block_given?
      end
    end

    def self.find_body_row_values(xml_cells)
      values = []
      xml_cells.elements.each("Cells/Cell") do |xml_cell|
        if value = xml_cell.children.first # finds <Value>...</Value>
          values << value.text
          next
        end
        values << nil
      end
      values
    end

    def self.find_body_column_names(body)
      header = REXML::XPath.first(body, "//RowType[text()='Header']")
      column_name = []
      header.parent.elements.each("Cells/Cell") do |header_cell|
        if value = header_cell.children.first # finds <Value>...</Value>
          column_name << value.text
          next
        end
        column_name << nil
      end
      column_name
    end
  end
end
