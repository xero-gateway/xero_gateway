module XeroGateway
  class Report
    include Money
    include Dates

    attr_reader   :errors
    attr_accessor :report_id, :report_name, :report_type, :report_titles, :report_date, :updated_at,
                  :body, :column_names

    def initialize(params={})
      @errors         ||= []
      @report_titles  ||= []
      @body           ||= []

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
          when 'ReportTitles'
            each_title(element) do |title|
              report.report_titles << title
            end
          when 'ReportDate'       then report.report_date = Date.parse(element.text)
          when 'UpdatedDateUTC'   then report.updated_at = parse_date_time(element.text)
          when 'Rows'
            report.column_names   ||= find_body_column_names(element)
            each_row_content(element) do |content_hash|
              report.body << OpenStruct.new(content_hash)
            end
        end
      end
      report
    end

  private

    def self.each_row_content(xml_element, &block)
      column_names   = find_body_column_names(xml_element).keys
      xpath_body     = REXML::XPath.first(xml_element, "//RowType[text()='Section']").parent
      rows_contents  = []
      xpath_body.elements.each("Rows/Row") do |xpath_cells|
        values        = find_body_cell_values(xpath_cells)
        content_hash  = Hash[column_names.zip values]
        rows_contents << content_hash
        yield content_hash if block_given?
      end
      rows_contents
    end

    def self.each_title(xml_element, &block)
      xpath_titles = REXML::XPath.first(xml_element, "//ReportTitles")
      xpath_titles.elements.each("//ReportTitle") do |xpath_title|
        title = xpath_title.text.strip
        yield title if block_given?
      end
    end

    def self.find_body_cell_values(xml_cells)
      values = []
      xml_cells.elements.each("Cells/Cell") do |xml_cell|
        if value = xml_cell.children.first # finds <Value>...</Value>
          values << value.text.strip if value.text
          next
        end
        values << nil
      end
      values
    end

    # returns something like { column_1: "Amount", column_2: "Description", ... }
    def self.find_body_column_names(body)
      header       = REXML::XPath.first(body, "//RowType[text()='Header']")
      names_map    = {}
      column_count = 0
      header.parent.elements.each("Cells/Cell") do |header_cell|
        column_count += 1
        column_key    = "column_#{column_count}".to_sym
        column_name   = nil
        name_value    = header_cell.children.first
        column_name   = name_value.text.strip unless name_value.blank? # finds <Value>...</Value>
        names_map[column_key] = column_name
      end
      names_map
    end

  end
end
