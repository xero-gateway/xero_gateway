require File.join(File.dirname(__FILE__), '../test_helper.rb')

class ReportTest < Test::Unit::TestCase
  include TestHelper
  include REXML

  context "creating report object" do
    should "create bank statement" do
      report = create_test_report_bank_statement
      assert_equal 'BankStatement', report.report_id
      assert_equal 'BankStatement', report.report_name
      assert_equal 'BankStatement', report.report_type
      assert report.report_titles.is_a? Array
      assert report.report_date.is_a? Date
      assert report.updated_at.is_a? Time
      assert report.column_names.is_a? Array
      assert report.body.is_a? Array
    end
  end

  context :from_xml do
    setup do
      xml_response = get_file("reports/bank_statement.xml")
      xml_response.gsub!(/\n +/,'')
      xml_doc = REXML::Document.new(xml_response)
      xpath_report = XPath.first(xml_doc, "//Report")
      @report = XeroGateway::Report.from_xml(xpath_report)
    end

    should "create a bank statement report" do
      assert @report.is_a?(XeroGateway::Report)
      assert_equal [], @report.errors
      assert_equal Date.parse("27 May 2014"), @report.report_date
      assert_equal "BankStatement", @report.report_id
      assert_equal "Bank Statement", @report.report_name
      expected_titles = ["Bank Statement", "Business Bank Account", "Demo Company (NZ)", "From 1 May 2014 to 27 May 2014"]
      assert_equal expected_titles, @report.report_titles
      assert_equal "BankStatement", @report.report_type
      assert_equal Time.parse("2014-05-26 22:36:07 +1200"), @report.updated_at
      expected_names = { :column_1=>"Date", :column_2=>"Description", :column_3=>"Reference", :column_4=>"Reconciled", :column_5=>"Source", :column_6=>"Amount", :column_7=>"Balance" }
      assert_equal expected_names, @report.column_names

      ###
      # REPORT BODY
      assert @report.body.is_a?(Array)

      # First = Opening Balance
      first_statement = @report.body.first
      assert_equal "2014-05-01T00:00:00", first_statement.column_1
      assert_equal "Opening Balance", first_statement.column_2
      assert_equal nil, first_statement.column_3
      assert_equal nil, first_statement.column_4
      assert_equal nil, first_statement.column_5
      assert_equal nil, first_statement.column_6
      assert_equal "15461.97", first_statement.column_7

      # Second = Bank Transaction/Statement
      second_statement = @report.body.second
      assert_equal "2014-05-01T00:00:00", second_statement.column_1
      assert_equal "Ridgeway Banking Corporation", second_statement.column_2
      assert_equal "Fee", second_statement.column_3
      assert_equal "No", second_statement.column_4
      assert_equal "Import", second_statement.column_5
      assert_equal "-15.00", second_statement.column_6
      assert_equal "15446.97", second_statement.column_7
    end
  end

end
