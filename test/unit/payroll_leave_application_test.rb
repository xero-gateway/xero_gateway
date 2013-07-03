require File.join(File.dirname(__FILE__), '../test_helper.rb')

class PayrollLeaveApplicationTest < Test::Unit::TestCase
  def setup
    @schema = LibXML::XML::Schema.document(LibXML::XML::Document.file(File.join(File.dirname(__FILE__), '../xsd/create_payroll_leave_application.xsd')))
  end

  # # Tests that the XML generated from a leave_application object validates against the Xero XSD
  # def test_build_xml
  #   leave_application = create_test_leave_application
  #   message = leave_application.to_xml

  #   # Check that the document matches the XSD
  #   assert LibXML::XML::Parser.string(message).parse.validate_schema(@schema), "The XML document generated did not validate against the XSD"
  # end

  # Tests that a leave_application can be converted into XML that Xero can understand, and then converted back to a leave_application
  def test_build_and_parse_xml
    leave_application = create_test_leave_application

    # Generate the XML message
    leave_application_as_xml = leave_application.to_xml

    # Parse the XML message and retrieve the leave_application element
    leave_application_element = REXML::XPath.first(REXML::Document.new(leave_application_as_xml), "/LeaveApplication")

    # Build a new leave_application from the XML
    result_leave_application = XeroGateway::Payroll::LeaveApplication.from_xml(leave_application_element)

    # Check the leave_application details
    assert_equal leave_application.title, result_leave_application.title
    assert_equal leave_application.description, result_leave_application.description
    assert_equal leave_application.leave_type_id, result_leave_application.leave_type_id
    assert_equal leave_application.employee_id, result_leave_application.employee_id
    assert_equal leave_application.start_date, result_leave_application.start_date
    assert_equal leave_application.end_date, result_leave_application.end_date
    assert_equal leave_application.leave_periods.first.number_of_units, result_leave_application.leave_periods.first.number_of_units
    assert_equal leave_application.leave_periods.first.pay_period_end_date, result_leave_application.leave_periods.first.pay_period_end_date
    assert_equal leave_application.leave_periods.first.pay_period_start_date, result_leave_application.leave_periods.first.pay_period_start_date
    assert_equal leave_application.leave_periods.first.leave_period_status, result_leave_application.leave_periods.first.leave_period_status
  end

  private

  def create_test_leave_application
  	leave_type_id = Time.now.to_f - 1.minute
    payroll_employee_id = Time.now.to_f - 2.minute
    leave_application = XeroGateway::Payroll::LeaveApplication.new()
    leave_application.title = "Leave Application Title"
    leave_application.description = "Leave Application Description"
    leave_application.leave_type_id = leave_type_id.to_i.to_s
    leave_application.employee_id = payroll_employee_id.to_i.to_s
    leave_application.start_date = Date.today
    leave_application.end_date = Date.today + 1.week
    leave_periods = []
    leave_period = XeroGateway::Payroll::LeavePeriod.new(
                                                :number_of_units => "3",
                                                :pay_period_end_date => Date.today + 1.month,
                                                :pay_period_start_date => Date.today,
                                                :leave_period_status => "SCHEDULED")  
    leave_periods << leave_period
    leave_application.leave_periods = leave_periods
    
   
    leave_application
  end
end
