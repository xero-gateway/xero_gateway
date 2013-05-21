require File.join(File.dirname(__FILE__), '../test_helper.rb')

class EmployeeTest < Test::Unit::TestCase
  def setup
    @schema = LibXML::XML::Schema.document(LibXML::XML::Document.file(File.join(File.dirname(__FILE__), '../xsd/create_employee.xsd')))
  end

  # Tests that the XML generated from a employee object validates against the Xero XSD
  def test_build_xml
    employee = create_test_employee

    message = employee.to_xml

    # Check that the document matches the XSD
    assert LibXML::XML::Parser.string(message).parse.validate_schema(@schema), "The XML document generated did not validate against the XSD"
  end

  # Tests that a employee can be converted into XML that Xero can understand, and then converted back to a employee
  def test_build_and_parse_xml
    employee = create_test_employee

    # Generate the XML message
    employee_as_xml = employee.to_xml

    # Parse the XML message and retrieve the employee element
    employee_element = REXML::XPath.first(REXML::Document.new(employee_as_xml), "/Employee")

    # Build a new employee from the XML
    result_employee = XeroGateway::Employee.from_xml(employee_element)

    # Check the employee details
    assert_equal employee, result_employee
  end

  private

  def create_test_employee
    employee = XeroGateway::Employee.new(:employee_id => "55555")
    employee.first_name = "EMPLOYEE FIRST NAME"
    employee.last_name = "EMPLOYEE LAST NAME"

    employee
  end
end
